
ref-aws() {
        eval $(sicom creds $1 -e)
}

# Automatically place virtualenvs in .virtualenvs so vim can use them
virenv() {
        virtualenv "/Users/rcarriga/.virtualenvs/"$1
}

ck() { 
        cd "$@" && k;
}
jk() { 
        j "$@" && k;
}