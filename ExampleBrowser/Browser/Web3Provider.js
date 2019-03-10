
class AccountsProcessor {
    process(params, callback) {
        callback(["0xb1c94904ccfb398b885fb755790117ac5baad709"]);
    }
    
    static get method() {
        return "eth_accounts";
    }
}

class NetVersionProcessor {
    process(params, callback) {
        callback("1");
    }
    
    static get method() {
        return "net_version";
    }
}

class TesseractProvider {
    constructor() {
        this._writeops = new Set(["eth_accounts", "net_version", "personal_sign", "eth_signTypedData"]);
        this._callbacks = {};
    }
    
    get provider() {
        if(this._provider === undefined) {
            this._provider = new Web3.providers.HttpProvider("https://mainnet.infura.io/v3/f20390fe230e46608572ac4378b70668");
        }
        
        return this._provider;
    }
    
    processRequest(request, callback) {
        /*if(!this._writeops.has(request.method)) {
            return false;
        }*/
        
        const id = request.id;
        
        this._callbacks[id] = (error, result) => {
            delete this._callbacks[id];
            
            if (error) {
                var reply = {id, jsonrpc: request.jsonrpc, error: error};
                alert(JSON.stringify(reply));
                callback(reply, null);
            } else {
                var reply = {id, jsonrpc: request.jsonrpc, result: result};
                //alert(JSON.stringify(reply));
                callback(null, reply);
            }
        }
        
        const jsonRequest = JSON.stringify(request);
        window.webkit.messageHandlers.tes.postMessage(jsonRequest);
        
        return true;
        
        /*var processor = this._processors[request.method];
        
        if(processor === undefined) {
            return false;
        }
        
        var cb = function(result) {
            var reply = {id: request.id, jsonrpc: request.jsonrpc, result: result};
            callback(null, reply);
        }
        
        processor.process(request.params, cb);
        
        return true;*/
    }
    
    sendAsync(...args) {
        this.processRequest(...args)
    }
    
    async send(request) {
        var p = new Promise( (resolve, reject) => {
            this.sendAsync(request, function(error, result) {
                           alert("DDDD" + result);
                if(error) {
                      reject(error);
                } else {
                      resolve(result);
                }
            });
        });
        
        var reply = await p;
        //alert("UUUUUU" + JSON.stringify(reply));
        return reply;
        
        //callback(null, reply);
        
        //alert("????????" + arguments[0].method);
    }
    
    /*send(request) {
        alert("????????" + request.id);
        return await new Promise(function(res, rej) {});
    }*/
    
    accept(id, error, result) {
        const callback = this._callbacks[id];
        
        if(callback) {
            const err = JSON.parse(error);
            const res = JSON.parse(result);
            
            callback(err, res);
        } else {
            alert("WTF??? Callback for id is not there: " + id);
        }
    }
}

class TesWeb3 {
    get currentProvider() {
        if(this._currentProvider === undefined) {
            this._currentProvider = new TesseractProvider();
        }
        
        return this._currentProvider;
    }
}

//window.web3 = new Web3(new TesseractProvider());
window.web3 = new TesWeb3();


window.onerror = function(error) {
    alert(error); // Fire when errors occur. Just a test, not always do this.
};

(function(window) {
 // Write your code here.
 // This function call will create own local scope, so you can create global vars here.
 // If you need to add something to window scope use window.something = ...
 
 
 
 })(window);

