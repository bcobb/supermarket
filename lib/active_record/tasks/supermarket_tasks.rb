require 'active_record/tasks/database_tasks'

module ActiveRecord
  module Tasks
    module DatabaseTasks
      register_task(/supermarket/, ActiveRecord::Tasks::PostgreSQLDatabaseTasks)
    end
  end
end
