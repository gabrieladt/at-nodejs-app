node[:docker_nginx_server].each do |name, image|
script "kill_all_containers" do  
  interpreter "bash"
  user "root"
  code <<-EOH
	/usr/bin/docker.io ps -a | grep #{name} | awk '{print $1}'| while read i; do /usr/bin/docker.io stop $i; done
	/usr/bin/docker.io ps -a | grep #{name} | awk '{print $1}'| while read i; do /usr/bin/docker.io rm -f $i; done
  EOH
end  
end
