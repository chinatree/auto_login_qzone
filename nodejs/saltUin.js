str = (function() {
    var htmlDecodeDict = {
        quot: '"',
        lt: "<",
        gt: ">",
        amp: "&",
        nbsp: " ",
        "#34": '"',
        "#60": "<",
        "#62": ">",
        "#38": "&",
        "#160": " "
    };
    var htmlEncodeDict = {
        '"': "#34",
        "<": "#60",
        ">": "#62",
        "&": "#38",
        " ": "#160"
    };
    return {
        decodeHtml: function(s) {
            s += "";
            return s.replace(/&(quot|lt|gt|amp|nbsp);/ig,
            function(all, key) {
                return htmlDecodeDict[key]
            }).replace(/&#u([a-f\d]{4});/ig,
            function(all, hex) {
                return String.fromCharCode(parseInt("0x" + hex))
            }).replace(/&#(\d+);/ig,
            function(all, number) {
                return String.fromCharCode( + number)
            })
        },
        encodeHtml: function(s) {
            s += "";
            return s.replace(/["<>& ]/g,
            function(all) {
                return "&" + htmlEncodeDict[all] + ";"
            })
        },
        trim: function(str) {
            str += "";
            var str = str.replace(/^\s+/, ""),
            ws = /\s/,
            end = str.length;
            while (ws.test(str.charAt(--end))) {}
            return str.slice(0, end + 1)
        },
        uin2hex: function(str) {
            var maxLength = 16;
            str = parseInt(str);
            var hex = str.toString(16);
            var len = hex.length;
            for (var i = len; i < maxLength; i++) {
                hex = "0" + hex
            }
            var arr = [];
            for (var j = 0; j < maxLength; j += 2) {
                arr.push("\\x" + hex.substr(j, 2))
            }
            var result = arr.join("");
            //eval('result="' + result + '"');
            return result
        },
        bin2String: function(a) {
            var arr = [];
            for (var i = 0,
            len = a.length; i < len; i++) {
                var temp = a.charCodeAt(i).toString(16);
                if (temp.length == 1) {
                    temp = "0" + temp
                }
                arr.push(temp)
            }
            arr = "0x" + arr.join("");
            arr = parseInt(arr, 16);
            return arr
        },
        utf8ToUincode: function(s) {
            var result = "";
            try {
                var length = s.length;
                var arr = [];
                for (i = 0; i < length; i += 2) {
                    arr.push("%" + s.substr(i, 2))
                }
                result = decodeURIComponent(arr.join(""));
                result = str.decodeHtml(result)
            } catch(e) {
                result = ""
            }
            return result
        },
        json2str: function(obj) {
            var result = "";
            if (typeof JSON != "undefined") {
                result = JSON.stringify(obj)
            } else {
                var arr = [];
                for (var i in obj) {
                    arr.push('"' + i + '":"' + obj[i] + '"')
                }
                result = "{" + arr.join(",") + "}"
            }
            return result
        },
        time33: function(str) {
            var hash = 0;
            for (var i = 0,
            length = str.length; i < length; i++) {
                hash = hash * 33 + str.charCodeAt(i)
            }
            return hash % 4294967296
        }
    }
})();

if(process.argv.length != 3) {
    console.log("usage: node " + process.argv[1] + " <qq>");
} else {
    var saltUin = str.uin2hex(process.argv[2]);
    console.log(saltUin); 
}
