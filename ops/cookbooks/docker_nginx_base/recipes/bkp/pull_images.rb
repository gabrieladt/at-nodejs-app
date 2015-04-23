# Pull each of our defined apps
node[:docker_nginx_server].each do |name, image|  
  script "pull_app_#{name}_image" do
    interpreter "bash"
    user "root"
    code <<-EOH
      docker pull #{image}
    EOH
  end
end  
