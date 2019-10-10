#### Fetch
```js
function bodyFetch(method, url, data) {
    return fetch(url, {
        method: method,
        body: JSON.stringify(data),
        credentials: 'include',
        headers: new Headers({
            "Content-Type": "application/json"
        })
    }).then(res => {
        console.log(method + " " + res.url + " " + res.status)
        consule.log("content-type: " + res.headers.get("content-type"))
        return res.text()
    }).then(res => console.log(res))
}

function urlFetch(method, url) {
    return fetch(url, {
        method: method,
//         body: JSON.stringify(data),
        credentials: 'include',
        headers: new Headers({
            "Content-Type": "application/json"
        })
    }).then(res => {
        console.log(method + " " + res.url + " " + res.status)
        consule.log("content-type: " + res.headers.get("content-type"))
        return res.text()
    }).then(res => console.log(res))
}
```