Rails.application.routes.draw do
    get 'minecraft_server/index'
    root 'minecraft_server#index'
    get 'ajax/start_server' => 'minecraft_server#start_server'
    get 'ajax/stop_server' => 'minecraft_server#stop_server'
end
