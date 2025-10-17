module Encryption

using Logging

export encrypt_rsa, decrypt_rsa,
       encrypt_aes_ecb, decrypt_aes_ecb,
       encrypt_aes_cbc, decrypt_aes_cbc,
       add_pkcs7_padding, remove_pkcs7_padding,
       encrypt_aes, decrypt_aes
"""
Run an openssl command with input data
"""
function run_openssl_cmd(cmd::Cmd, input_data::Vector{UInt8})
    stdout_buf = IOBuffer()
    stderr_buf = IOBuffer()
    process = run(pipeline(cmd, stdin=IOBuffer(input_data), stdout=stdout_buf, stderr=stderr_buf))
    
    if process.exitcode != 0
        stderr_output = String(take!(stderr_buf))
        throw(ErrorException("openssl command failed with exit code $(process.exitcode): $stderr_output"))
    end

    return take!(stdout_buf)
end

# ======================
# RSA (with custom segmentation)
# ======================

const RSA_ENCRYPT_BLOCK_SIZE = 100
const RSA_DECRYPT_BLOCK_SIZE = 128

"""
RSA public key encryption (PKCS1, segmented)
"""
function encrypt_rsa(data::Vector{UInt8}, pub_key_path::String)::Vector{UInt8}
    encrypted_chunks = IOBuffer()
    cmd = `openssl pkeyutl -encrypt -pubin -inkey $pub_key_path -pkeyopt rsa_padding_mode:pkcs1`

    for i in 1:RSA_ENCRYPT_BLOCK_SIZE:length(data)
        chunk = data[i:min(i + RSA_ENCRYPT_BLOCK_SIZE - 1, end)]
        encrypted_chunk = run_openssl_cmd(cmd, chunk)
        write(encrypted_chunks, encrypted_chunk)
    end
    return take!(encrypted_chunks)
end

"""
RSA private key decryption (PKCS1, segmented)
"""
function decrypt_rsa(data::Vector{UInt8}, priv_key_path::String)::Vector{UInt8}
    if length(data) % RSA_DECRYPT_BLOCK_SIZE != 0
        throw(ArgumentError("Invalid RSA encrypted data length. Must be multiple of $RSA_DECRYPT_BLOCK_SIZE"))
    end
    decrypted_chunks = IOBuffer()
    cmd = `openssl pkeyutl -decrypt -inkey $priv_key_path -pkeyopt rsa_padding_mode:pkcs1 -pkeyopt rsa_pkcs1_implicit_rejection:0`

    for i in 1:RSA_DECRYPT_BLOCK_SIZE:length(data)
        chunk = data[i:(i + RSA_DECRYPT_BLOCK_SIZE - 1)]
        decrypted_chunk = run_openssl_cmd(cmd, chunk)

        write(decrypted_chunks, decrypted_chunk)
    end
    return take!(decrypted_chunks)
end


# ======================
# PKCS7 Padding
# ======================

"""
PKCS7 padding
"""
function add_pkcs7_padding(data::Vector{UInt8})::Vector{UInt8}
    padding_len = 16 - length(data) % 16
    if padding_len == 0
        padding_len = 16
    end
    return vcat(data, fill(UInt8(padding_len), padding_len))
end

"""
Remove PKCS7 padding
"""
function remove_pkcs7_padding(data::Vector{UInt8})::Vector{UInt8}

    @show padding_len = Int(data[end])
    return data[1:end-padding_len]
end

# ======================
# AES-128-ECB
# ======================

"""
AES-128-ECB encryption (Futu-specific zero-padding + 16-byte tail block)
"""
function encrypt_aes_ecb(data::Vector{UInt8}, key::String)::Vector{UInt8}
    len_src = length(data)
    mod_tail_len = len_src % 16

    # Pad to a multiple of 16 (zero-padding)
    padded_data = if mod_tail_len != 0
        vcat(data, zeros(UInt8, 16 - mod_tail_len))
    else
        data
    end

    key_hex = bytes2hex(Vector{UInt8}(key))
    encrypted_data = run_openssl_cmd(`openssl enc -aes-128-ecb -K $key_hex -nosalt -nopad`, padded_data)

    # Add a 16-byte tail block: the last byte records mod_tail_len
    data_tail = vcat(zeros(UInt8, 15), UInt8(mod_tail_len))
    return vcat(encrypted_data, data_tail)
end

"""
AES-128-ECB decryption (Futu-specific zero-padding removal)
"""
function decrypt_aes_ecb(data::Vector{UInt8}, key::String)::Vector{UInt8}
    if isempty(data)
        return UInt8[]
    end
    if length(data) < 16
        throw(ErrorException("Data too short for AES-ECB"))
    end

    data_real = data[1:end-16]
    tail_real_len = Int(data[end])
    if !(0 <= tail_real_len <= 15)
        throw(ErrorException("Invalid tail_real_len: $tail_real_len"))
    end

    key_hex = bytes2hex(Vector{UInt8}(key))
    de_data = run_openssl_cmd(`openssl enc -d -aes-128-ecb -K $key_hex -nosalt -nopad`, data_real)

    if tail_real_len != 0
        cut_len = 16 - tail_real_len
        return de_data[1:end-cut_len]
    else
        return de_data
    end
end

# ======================
# AES-128-CBC
# ======================

"""
AES-128-CBC encryption (with PKCS7 padding)
"""
function encrypt_aes_cbc(data::Vector{UInt8}, key::String, iv::String)::Vector{UInt8}
    padded_data = add_pkcs7_padding(data)
    key_hex = bytes2hex(Vector{UInt8}(key))
    iv_hex  = bytes2hex(Vector{UInt8}(iv))
    return run_openssl_cmd(`openssl enc -aes-128-cbc -K $key_hex -iv $iv_hex -nosalt -nopad`, padded_data)
end

"""
AES-128-CBC decryption (with PKCS7 padding)
"""
function decrypt_aes_cbc(data::Vector{UInt8}, key::String, iv::String)::Vector{UInt8}
    if isempty(data)
        return UInt8[]
    end
    if length(data) % 16 != 0
        throw(ErrorException("Data length not multiple of 16 for CBC decryption"))
    end

    key_hex = bytes2hex(Vector{UInt8}(key))
    iv_hex  = bytes2hex(Vector{UInt8}(iv))
    cmd = `openssl enc -d -aes-128-cbc -K $key_hex -iv $iv_hex -nosalt -nopad`

    @show decrypted_data = run_openssl_cmd(cmd, data)
    return remove_pkcs7_padding(decrypted_data)
end

end # module Encryption
