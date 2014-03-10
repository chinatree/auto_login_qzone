<?php
$stdin = fopen('php://stdin', 'r');
function fill_blank($input, $pad_length, $pad_string = ' ', $pad_type = STR_PAD_BOTH){
    $data = str_pad($input, $pad_length, $pad_string, $pad_type);
    return $data;
}

function get_all($stdin){
    while($line = fgets($stdin)){
        $line = preg_replace('/_Callback\((.*)\);/', '$1', $line);
        $retObject = json_decode($line);
        var_dump($retObject);
    }
}

function get_msglist($stdin){
    while($line = fgets($stdin)){
        $line = preg_replace('/_Callback\((.*)\);/', '$1', $line);
        $retObject = json_decode($line);        
        print_r(fill_blank('tid', 24) . fill_blank("name(uin)", 40) . fill_blank("create_time", 21) . fill_blank("comments", 10) . fill_blank("content", 50, ' ', STR_PAD_RIGHT) . "\n");
        foreach($retObject->msglist as $k => $v){
            print_r(fill_blank($v->tid, 24) . fill_blank($v->name. '(' . $v->uin . ')', 40)  . fill_blank(date('Y-m-d H:i:s', $v->created_time), 21)  . fill_blank($v->cmtnum, 10) . fill_blank($v->content, 50, ' ', STR_PAD_RIGHT) . "\n");
        }
    }
}

function get_userinfo($stdin){
    while($line = fgets($stdin)){
        $line = preg_replace('/_Callback\((.*)\);/', '$1', $line);
        $retObject = json_decode($line);        
        print_r(fill_blank("name(uin)", 20) . fill_blank("createTime", 21). fill_blank("comments", 10) . fill_blank("content", 50, ' ', STR_PAD_RIGHT) . "\n");
        $v = $retObject->usrinfo;
        print_r(fill_blank($v->name. '(' . $v->uin . ')', 20) . fill_blank($v->createTime, 24) . fill_blank($v->cmtnum, 10) . fill_blank($v->msg, 50, ' ', STR_PAD_RIGHT) . "\n");
    }
}

function get_tid($stdin){
    while($line = fgets($stdin)){
        $line = preg_replace('/_Callback\((.*)\);/', '$1', $line);
        $retObject = json_decode($line);        
        print_r(fill_blank('tid', 24) . "\n");
        foreach($retObject->msglist as $k => $v){
            print_r(fill_blank($v->tid, 24) . "\n");
        }
    }
}

if($argv[1] == "all")
    get_all($stdin);

if($argv[1] == "msglist")
    get_msglist($stdin);

if($argv[1] == "userinfo")
    get_userinfo($stdin);

if($argv[1] == "list_tid")
    get_tid($stdin);
