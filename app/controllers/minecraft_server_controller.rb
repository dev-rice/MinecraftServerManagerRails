require 'pg'
class MinecraftServerController < ApplicationController
    attr_reader :server, :conn, :server_table, :worlds_table

    def initialize
        initialize_db_connection
        @server_table = ServerTable.new(conn, 'server')
        @worlds_table = WorldsTable.new(conn, 'worlds')
        @server = MinecraftServer.new(server_table, worlds_table)
    end

    def initialize_db_connection
        @conn = PG::Connection.open(:dbname => dbname)
    end

    def dbname
        'MinecraftServerManagerRails_development'
    end

    def disconnect_db_connection
        @conn.close()
    end

    def start_server()
        render nothing: true

        world_name = params[:world_name]
        world = worlds_table.get_world(world_name)

        if world
            server.start_world(world)
        end

        disconnect_db_connection
    end

    def stop_server
        render nothing: true

        server.stop
        disconnect_db_connection
    end

    def get_status
        render text: "#{server.running}"
        disconnect_db_connection
    end

    def get_server_info_string
        if !server.running
            render text: ""
            disconnect_db_connection
            return
        end
        
        socket = MinecraftServerSocket.new("192.168.1.112", 25565)
        response = ServerResponse.new(socket.byte_response)

        render text: "#{response.as_string}"
        disconnect_db_connection
    end

    def get_worlds
        worlds = worlds_table.get_worlds()
        render text: "#{worlds.keys}"
        disconnect_db_connection
    end

    def get_server_log
        render text: "#{server.log_text}"
        disconnect_db_connection
    end
end
