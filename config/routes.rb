Rails.application.routes.draw do
    get 'minecraft_server/index'
    root 'minecraft_server#index'
    get 'ajax/start_server' => 'minecraft_server#start_server'
    get 'ajax/stop_server' => 'minecraft_server#stop_server'
    get 'ajax/get_status' => 'minecraft_server#get_status'
    get 'ajax/get_worlds' => 'minecraft_server#get_worlds'
    get 'ajax/get_server_log' => 'minecraft_server#get_server_log'

end
