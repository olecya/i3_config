#!/usr/bin/ruby
require 'json'

# recursively walk tree to find all containers
# return an array of names followed by [id]
def get_containers tree
    containers = []
    # try to return only useful containers
    if (tree['nodes']+tree['floating_nodes']).empty? && tree['type'] == 2 &&
        !(tree['name'] =~ /^i3bar for output/)
        containers << tree['name'] + " [#{tree['id']}]"
    end
    (tree['nodes'] + tree['floating_nodes']).each do |node|
        containers += get_containers(node)
    end
    containers
end

IO.popen(['dmenu', '-i', '-p', 'window jump'], 'r+') do |dmenu|
    dmenu.puts(get_containers(JSON.load(`i3-msg -t get_tree`)))
    dmenu.close_write
    id = dmenu.read.split(/\[|\]/).last
    exec "i3-msg [con_id=#{id}] focus"
end