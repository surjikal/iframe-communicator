###
iframe-communicator
Copyright (c) 2012 Nicolas Porter <porter.nicolas@gmail.com>
MIT Licensed

Inspired by "Getting access to a phone’s camera from a web page"
http://hackerluddite.wordpress.com/2012/04/15/getting-access-to-a-phones-camera-from-a-web-page/
###

class IFrameCommunicator

    constructor: ->
        @_callbacks = {}
        @_messageListeners = {}


    initializeParent: (@targetUrl, @iframeId, done) =>
        iframeElement = document.getElementById iframeId
        @target = iframeElement.contentWindow

        iframeElement.addEventListener 'load', =>
            window.addEventListener 'message', @_receiveMessage, false
            done()
        , false


    initializeIframe: (@targetUrl) =>
        window.addEventListener 'message', @_receiveMessage, false
        @addMessageListener @_REMOTE_CALLBACK_MESSAGE_TYPE, @_handleRemoteCallback
        @target = window.parent


    postMessage: (messageType, messageData, callback) =>
        if typeof messageData is 'function'
            callback = messageData
            messageData = {}

        message = {type: messageType, data: messageData}

        if callback
            callbackId = generateCallbackId()
            @_callbacks[callbackId] = callback
            message.callbackId = callbackId

        @target.postMessage (@_serializeMessage message), @targetUrl


    addMessageListener: (messageType, messageListener) =>
        @_messageListeners[messageType] = messageListener


    _receiveMessage: (e) =>
        return if (e.origin isnt @targetUrl) or (not e.data)

        @_deserializeMessage e.data, (err, message) =>
            return console.error "Could not deserialize message: '#{err}'" if err
            return console.error "Received message with no type." if not message.type or message.type == 'undefined'

            messageListener = @_messageListeners[message.type] or @_handleUnhandledMessageType
            messageListener message.data, (args...) =>
                @_remoteCallback message.callbackId, args if message.callbackId


    _REMOTE_CALLBACK_MESSAGE_TYPE: '__remoteCallback'
    _remoteCallback: (callbackId, args) =>
        @postMessage @_REMOTE_CALLBACK_MESSAGE_TYPE, {callbackId, args}


    _handleRemoteCallback: (message) =>
        return if not message.callbackId
        callback = @_callbacks[message.callbackId]
        callback message.args...


    _handleUnhandledMessageType: (message) ->
        console.error "Received unknown message type '#{message.type}'"


    _serializeMessage: (message) ->
        JSON.stringify message


    _deserializeMessage: (message, done) ->
        done null, (JSON.parse message)


generateCallbackId = do ->
    seed = 0
    -> seed = (seed+1) % 128


window.IFrameCommunicator = IFrameCommunicator
