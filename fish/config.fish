if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g fish_greeting


#c compiler
function crun
    set file $argv[1]
    set name (string replace -r '\.c$' '' $file)

    gcc $file -lm -o $name && ./$name
end
starship init fish | source

fish_add_path /home/shubham/.spicetify
