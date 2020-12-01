local redis_conf = {
    auth = { host = "127.0.0.1", port = 6379, db = 0},
    hot = { host = "127.0.0.1", port = 6379, db = 1 }
}


return redis_conf
