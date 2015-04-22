directory "/nginx_base/" do
        owner 'root'
        group 'root'
        mode '0775'
end
directory "/nginx_base/conf.d" do
        owner 'root'
        group 'root'
        mode '0775'
end
directory "/nginx_base/sites-enabled" do
        owner 'root'
        group 'root'
        mode '0775'
end
directory "/nginx_base/certs" do
        owner 'root'
        group 'root'
        mode '0775'
end
directory "/nginx_base/logs" do
        owner 'root'
        group 'root'
        mode '0775'
end
directory "/nginx_base/www" do
        owner 'root'
        group 'root'
        mode '0775'
end

template "/nginx_base/www/index.htm" do
	source "index.htm.erb"
	mode 0775
	owner 'root'
	group 'root'
end

package "jq" do  
	package_name "jq"
	action :install
end 

#service "docker.io" do
#  provider Chef::Provider::Service::Upstart
#  supports :status => true, :restart => true, :reload => true
#end

#package "docker" do
#        package_name "docker.io"
#        action :install
#        notifies :restart, resources(:service => "docker.io"), :immediate
#end

node[:docker_nginx_server].each do |name, image|
	script "root_container" do
		interpreter "bash"
		user "root"
		code <<-EOH
docker pull #{image}


/usr/bin/docker.io ps -a | grep #{name} | grep Exited
if [ $? -eq 0 ]; then
	/usr/bin/docker.io stop #{name} 
	/usr/bin/docker.io rm #{name} 
	docker run --name #{name} -d -p 80:80 -p 443:443 -v /nginx_base/sites-enabled:/etc/nginx/sites-enabled -v /nginx_base/certs:/etc/nginx/certs -v /nginx_base/logs:/var/log/nginx -v /nginx_base/www:/var/www/html -v /nginx_base/conf.d:/etc/nginx/conf.d  #{image} 
fi

/usr/bin/docker.io ps -a | grep #{name}
if [ $? -ne 0 ]; then
	docker run --name #{name} -d -p 80:80 -p 443:443 -v /nginx_base/sites-enabled:/etc/nginx/sites-enabled -v /nginx_base/certs:/etc/nginx/certs -v /nginx_base/logs:/var/log/nginx -v /nginx_base/www:/var/www/html -v /nginx_base/conf.d:/etc/nginx/conf.d  #{image} 
fi


/usr/bin/docker.io ps -a | grep #{name} | grep -v "Up " 
if [ $? -eq 0 ]; then
        service docker.io restart
        /usr/bin/docker.io rm -f #{name} 
        docker run --name #{name} -d -p 80:80 -p 443:443 -v /nginx_base/sites-enabled:/etc/nginx/sites-enabled -v /nginx_base/certs:/etc/nginx/certs -v /nginx_base/logs:/var/log/nginx -v /nginx_base/www:/var/www/html -v /nginx_base/conf.d:/etc/nginx/conf.d  #{image} 
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
                docker run --name #{name} -d -p 80:80 -p 443:443 -v /nginx_base/sites-enabled:/etc/nginx/sites-enabled -v /nginx_base/certs:/etc/nginx/certs -v /nginx_base/logs:/var/log/nginx -v /nginx_base/www:/var/www/html -v /nginx_base/conf.d:/etc/nginx/conf.d  #{image} 
		sleep 3
        else
                echo "#{name} up to date"
        fi
done
		EOH
	end

        execute "docker_hup_nginx_base" do
                #command "docker kill -s HUP #{name}"
                command "docker restart #{name}"
                action :nothing
        end

        template "/nginx_base/sites-enabled/localhost.conf" do
                source "nginx_vhost.conf.erb"
                mode 0755
                group 'root'
                owner 'root'
                notifies :run, "execute[docker_hup_nginx_base]", :immediately
        end

end
node[:apps_containers].each do |name, image|

        template "/nginx_base/conf.d/#{name}_upstream.conf" do
                source "upstream.conf.erb"
                mode 0755
                group 'root'
                owner 'root'
                variables(
                        :app_name => "#{name}",
                        :host => "172.17.42.1",
                        :port => "#{node[name][:docker_port]}"
                )
                notifies :run, "execute[docker_hup_nginx_base]", :immediately
        end

        template "/nginx_base/sites-enabled/#{name}_vhost.conf" do
                source "app_nginx_external.conf.erb"
                mode 0755
                group 'root'
                owner 'root'
                variables(
                        :app_name => "#{name}",
                        :domain => " #{node[name][:domain]}"
                )
                notifies :run, "execute[docker_hup_nginx_base]", :immediately
        end
end

