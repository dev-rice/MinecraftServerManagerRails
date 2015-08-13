require 'pg'
class MinecraftServerController < ApplicationController
    attr_reader :server, :conn, :server_table, :worlds_table

    def initialize
        initialize_db_connection
        @server_table = ServerTable.new(conn, 'server')
        @worlds_table = WorldsTable.new(conn, 'worlds')
        @server = MinecraftServer.new(server_table)
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

        successful = true
        world_name = params[:world_name]
        worlds = worlds_table.get_worlds()
        world = worlds[world_name]

        if (world)
            server.start_world(world)
        else
            successful = false
        end

        disconnect_db_connection

        return successful
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

    def get_worlds
        worlds = worlds_table.get_worlds()
        render text: "#{worlds.keys}"
        disconnect_db_connection
    end

end
