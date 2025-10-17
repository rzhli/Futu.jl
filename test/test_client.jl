using Revise
using Futu
rsa_key_path = get(ENV, "FUTU_RSA_KEY_PATH", joinpath(homedir(), ".futu", "private.pem"))

client = OpenDClient(rsa_private_key_path = rsa_key_path)
connect!(client)
is_connected(client)
# 获取全局状态
global_state = get_global_state(client)

# 获取延迟统计
stats = get_delay_statistics(client)

# 获取用户信息
user_info = get_user_info(client; flag = UserInfoField.Basic)
user_info = get_user_info(client; flag = UserInfoField.API)
user_info = get_user_info(client; flag = UserInfoField.QotRight)
user_info = get_user_info(client; flag = UserInfoField.Disclaimer)
user_info = get_user_info(client; flag = UserInfoField.Update)
user_info = get_user_info(client; flag = UserInfoField.WebKey)

disconnect!(client)
