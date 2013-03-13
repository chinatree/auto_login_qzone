function getGTK(str){
   var hash = 5381;
   for(var i = 0, len = str.length; i < len; ++i)
   {
   hash += (hash << 5) + str.charAt(i).charCodeAt();
   }
   return hash & 0x7fffffff;
}

if(process.argv.length != 3) {
    console.log("usage: node " + process.argv[1] + " <qq> <password> <verifycode>");
} else {
    var gtk = getGTK(process.argv[2]);
    console.log(gtk); 
}
