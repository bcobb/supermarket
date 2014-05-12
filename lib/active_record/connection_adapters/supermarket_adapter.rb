require 'active_record/connection_adapters/postgresql_adapter'
require 'active_record/tasks/supermarket_tasks'

module ActiveRecord
  module ConnectionHandling
    #
    # Given an adapter named +supermarket+, ActiveRecord expects there to be a
    # +supermarket_connection+ method provided by the +ConnectionHandling+
    # module.
    #
    # @note This method is identical to that of the +postgresql_connection+
    #   method provided by ActiveRecord, with the exception that it returns a
    #   +SupermarketAdapter+ instead of a +PostgreSQLAdapter+.
    #
    def supermarket_connection(config)
      conn_params = config.symbolize_keys

      conn_params.delete_if { |_, v| v.nil? }

      # Map ActiveRecords param names to PGs.
      conn_params[:user] = conn_params.delete(:username) if conn_params[:username]
      conn_params[:dbname] = conn_params.delete(:database) if conn_params[:database]

      # Forward only valid config params to PGconn.connect.
      conn_params.keep_if { |k, _| VALID_CONN_PARAMS.include?(k) }

      # The postgres drivers don't allow the creation of an unconnected PGconn object,
      # so just pass a nil connection object for the time being.
      ConnectionAdapters::SupermarketAdapter.new(nil, logger, conn_params, config)
    end
  end

  module ConnectionAdapters
    class SupermarketAdapter < PostgreSQLAdapter
      #
      # Supermarket only enables extensions when the connected user has
      # SUPERUSER privileges
      #
      def enable_extension(*args)
        super if superuser?
      end

      private

      def superuser?
        rolname = exec_query('SELECT current_user').rows.first.first

        exec_query(
          %{SELECT rolsuper FROM pg_roles WHERE rolname='#{rolname}'}
        ).rows.first.first == 't'
      end
    end
  end
end
