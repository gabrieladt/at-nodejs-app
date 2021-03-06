node[:apps_containers_prod].each do |name, image|
	script "deploy_app_prod" do
		interpreter "bash"
		user "root"
		code <<-EOH
/usr/bin/docker ps -a | grep #{name} | grep Exited 

if [ $? -eq 0 ]; then
        /usr/bin/docker stop #{name} 
        /usr/bin/docker rm #{name} 
	docker run --name #{name} -d -p #{node[name][:docker_port]}:3000 #{image} 
fi

/usr/bin/docker ps -a | grep #{name}
if [ $? -ne 0 ]; then
        docker run --name #{name} -d -p #{node[name][:docker_port]}:3000 #{image} 
fi

/usr/bin/docker ps -a | grep #{name} | grep -v "Up " 
if [ $? -eq 0 ]; then
	service docker restart
        /usr/bin/docker rm -f #{name} 
        docker run --name #{name} -d -p #{node[name][:docker_port]}:3000 #{image} 
fi

/usr/bin/docker ps -a | grep #{name} | awk '{print $1}'| while read i 
        do 
        LATEST=`docker inspect --format "{{.Id}}" #{image}`
        RUNNING=`docker inspect --format "{{.Image}}" $i`
        echo "Latest:" $LATEST
        echo "Running:" $RUNNING
        if [ "$RUNNING" != "$LATEST" ];then
                /usr/bin/docker stop $i 
                /usr/bin/docker rm $i 
        	docker run --name #{name} -d -p #{node[name][:docker_port]}:3000 #{image} 
        else
                echo "#{name} up to date"
        fi
done
	EOH
	end
end
