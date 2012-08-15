# Iframe Communicator

Sane API for communication between an iframe and its parent. This is useful for phonegap development,
as it allows you access a phone's hardware from a remote website.

The inspiration for this project came from:
http://hackerluddite.wordpress.com/2012/04/15/getting-access-to-a-phones-camera-from-a-web-page/

It's written in CoffeeScript. If you want it in JavaScript, just compile it ;)

## Usage example

### parent.jade

```jade
!!!
html
    head
        script(type="text/javascript", charset="utf-8", src="js/cordova-2.0.0.js")
        script(type="text/javascript", charset="utf-8", src="js/iframe-communicator.js")

        link(rel='stylesheet', href="css/style.css")

    body
        iframe#remote-site(src='')


    :coffeescript
        REMOTE_URL = "http://example.com"
        IFRAME_ID = 'remote-site'

        document.addEventListener 'deviceready', ->
            communicator = new IFrameCommunicator()

            communicator.initializeParent REMOTE_URL, IFRAME_ID, ->

                communicator.addMessageListener 'camera', (message, done) ->
                    cameraOptions =
                        quality: 50,
                        destinationType: Camera.DestinationType.DATA_URL,
                        targetWidth: 640,
                        targetHeight: 640

                    onSuccess = (imageData) ->
                        done null, imageData

                    onError = (message) ->
                        done message

                    navigator.camera.getPicture onSuccess, onError, cameraOptions

            iframe = document.getElementById IFRAME_ID
            iframe.src = REMOTE_URL
```

### remote.jade

```jade
!!!
html
    head
        script(type="text/javascript", src="js/jquery.min.js")
        script(type="text/javascript", charset="utf-8", src="js/iframe-communicator.js")

    body
        h1 Testing thing thing out...
        button#picture(type="button") Take a picture!!
        .content


    :coffeescript
        REMOTE_URL = "file://"

        $ ->
            communicator = new IFrameCommunicator()
            communicator.initializeIframe REMOTE_URL

            $('#picture').click ->
                alert 'Clicked button!'

                communicator.postMessage 'camera', (err, imageData) ->
                    return alert 'Something went wrong while getting the picture.' if err
                    $image = $('<img/>')
                    $('.content').prepend $image
                    $image.attr 'src', 'data:image/jpg;base64,' + imageData
```


