include_recipe 'deploy'
include_recipe 'dependencies'

node[:deploy].each do |application, deploy|
  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end
end

node[:dedalus_apps_containers].each do |name, image|
	directory "/apps/#{name}/sites-enabled" do
	        owner 'deploy'
	        group 'root'
	        mode '0775'
	end
	directory "/apps/#{name}/" do
	        owner 'deploy'
	        group 'root'
	        mode '0775'
	end
	directory "/apps/#{name}/certs" do
	        owner 'deploy'
	        group 'root'
	        mode '0775'
	end
	directory "/apps/#{name}/logs" do
	        owner 'deploy'
	        group 'root'
	        mode '0775'
	end
	directory "/apps/#{name}/www" do
	        owner 'deploy'
	        group 'root'
	        mode '0775'
	end

	script "deploy_app" do
		interpreter "bash"
		user "root"
		code <<-EOH
docker pull #{image}

/usr/bin/docker.io ps -a | grep #{name} | grep Exited 

if [ $? -eq 0 ]; then
        /usr/bin/docker.io stop #{name} 
        /usr/bin/docker.io rm #{name} 
	docker run --name #{name} -d -p #{node[name][:docker_port]}:80 -v /apps/#{name}/sites-enabled:/etc/nginx/sites-enabled  -v /apps/#{name}/logs:/var/log/nginx -v /apps/#{name}:/apps/#{name}  #{image} 
fi

/usr/bin/docker.io ps -a | grep #{name}
if [ $? -ne 0 ]; then
        docker run --name #{name} -d -p #{node[name][:docker_port]}:80 -v /apps/#{name}/sites-enabled:/etc/nginx/sites-enabled -v /apps/#{name}/logs:/var/log/nginx -v /apps/#{name}:/apps/#{name}  #{image} 
fi

/usr/bin/docker.io ps -a | grep #{name} | grep -v "Up " 
if [ $? -eq 0 ]; then
	service docker.io restart
        /usr/bin/docker.io rm -f #{name} 
        docker run --name #{name} -d -p #{node[name][:docker_port]}:80 -v /apps/#{name}/sites-enabled:/etc/nginx/sites-enabled -v /apps/#{name}/logs:/var/log/nginx -v /apps/#{name}:/apps/#{name}  #{image} 
fi

/usr/bin/docker.io ps -a | grep #{name} | awk '{print $1}'| while read i 
        do 
        LATEST=`docker inspect --format "{{.Id}}" #{image}`
        RUNNING=`docker inspect --format "{{.Image}}" $i`
        echo "Latest:" $LATEST
        echo "Running:" $RUNNING
        if [ "$RUNNING" != "$LATEST" ];then
                /usr/bin/docker.io stop $i 
                /usr/bin/docker.io rm $i 
                docker run --name #{name} -d -p #{node[name][:docker_port]}:80 -v /apps/#{name}/sites-enabled:/etc/nginx/sites-enabled -v /apps/#{name}/logs:/var/log/nginx -v /apps/#{name}:/apps/#{name}  #{image} 
        else
                echo "#{name} up to date"
        fi
done
	EOH
	end

        execute "docker_hup_app" do
                command "docker kill -s HUP #{name}"
                action [ :nothing ]
        end

        template "/apps/#{name}/sites-enabled/#{name}.conf" do
                source "nginx_vhost.conf.erb"
                mode 0755
                group 'root'
                owner 'root'
		 variables(
                        :app_name => "#{name}"
                )
                notifies :run, "execute[docker_hup_app]", :immediately
        end
	
	execute "docker_app_restart" do
                command "docker restart #{name}"
                action [ :run ]
        end
end
