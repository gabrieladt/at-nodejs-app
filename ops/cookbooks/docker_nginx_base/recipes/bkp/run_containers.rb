# Run each app. We don't expose any ports since Nginx will handle all incoming traffic as a proxy
#docker run -d -p 80:80 --name=#{name} #{image}
node[:docker_nginx_server].each do |name, image|  
  script "run_app_#{name}_container" do
    interpreter "bash"
    user "root"
    code <<-EOH
	docker run -name #{name} -d -p 80:80 -v /apps/nginx/sites-enabled:/etc/nginx/sites-enabled -v /apps/nginx/certs:/etc/nginx/certs -v /apps/nginx/logs:/var/log/nginx /apps/:/var/www/html  #{image} 
	EOH
  end
end

