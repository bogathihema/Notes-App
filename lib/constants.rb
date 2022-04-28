module Constants
  module Permissions
    READ = "read"
    UPDATE = ["read", "update"]
    OWNER = ["read", "update", "share", "delete"]
  end

  module Role
    OWNER = "owner"
  end
end
