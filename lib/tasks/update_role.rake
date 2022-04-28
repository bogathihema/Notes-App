namespace :db do
	desc "Update Role"
	task :update_role, [:email] => :environment do |task, args|
    user = User.where(username: args[:email])
    user.update(role: Constants::Role::OWNER)
  end
end
