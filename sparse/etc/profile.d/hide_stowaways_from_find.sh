find() {
    p=${1:-.}
    /bin/find "$p" ! \( -path "${p/%\//}/data/.stowaways" -prune \) "${@:2}"
}
