#!/usr/bin/python

#Module documentation
"This is a server daemon module of the ADSG cloud module; developed by liu_yt@neusoft.com"

#Module imports
import sys
import os
import re
import time
import string
import optparse
import signal
import threading

import xml.dom.minidom

from cloud_common import (ec2_connection, region_error, key_error, instance_id_invalid)

#Global variable

monitor_list = {}
#protect monitor_list
mutex = threading.Lock()

config_file = 'None'
reconfig = False
quit = False
notifier = 'None'
notifier_tag_name = 'notifier'
monitor_tag_name = 'monitor'
scale_tag_name = 'scale'
no_scale_tag_name = 'no_scale'
instance_tag_name = 'instance'
monitor_name_tag_name = 'name'
monitor_status_tag_name = 'status'
access_key_tag_name = 'access_key'
cloud_type_tag_name = 'cloud_type'
key_id_tag_name = 'key_id'
secret_key_tag_name = 'secret_key'
region_tag_name = 'region'
down_time_tag_name = 'down_time'
up_time_tag_name = 'up_time'
daily_config = 'daily'
year_tag_name = 'year'
month_tag_name = 'month'
day_tag_name = 'day'
hour_tag_name = 'hour'
minute_tag_name = 'minute'
second_tag_name = 'second'
date_tag_name = 'date'
time_tag_name = 'time'


month_day = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30 ,31]

#Class

class region_config_error(BaseException):
    pass

class access_config_error(BaseException):
    pass

class instance_config_error(BaseException):
    pass

class instance_info(object):
    def __init__(self, id, status, ip, info):
        self.id = id
        self.status = status
        self.ip = ip
        self.info = info

class scale_time(object):
    def __init__(self, use_curr = 0, **kwargs):
        if use_curr == 0:
            self.day = kwargs['day']
            if self.day != daily_config:
                self.year = kwargs['year']
                self.mon = kwargs['mon']
            self.hour = kwargs['hour']
            self.min = kwargs['min']
            self.sec = kwargs['sec']
        else:
            curr_time = time.localtime()
            self.year = curr_time.tm_year
            self.mon = curr_time.tm_mon
            self.day = curr_time.tm_mday
            self.hour = curr_time.tm_hour
            self.min = curr_time.tm_min
            self.sec = curr_time.tm_sec

    def __cmp__(self, other):
        if self.day != daily_config and other.day != daily_config:
            if self.year > other.year:
                print 'year %d > %d'  % (self.year, other.year)
                return 1
            if self.year < other.year:
                print 'year %d < %d'  % (self.year, other.year)
                return -1
            if self.mon > other.mon:
                print 'mon %d > %d'  % (self.mon, other.mon)
                return 1
            if self.mon < other.mon:
                print 'mon %d < %d'  % (self.mon, other.mon)
                return -1
            if self.day > other.day:
                print 'day %d > %d'  % (self.day, other.day)
                return 1
            if self.day < other.day:
                print 'day %d < %d'  % (self.day, other.day)
                return -1
        if self.hour > other.hour:
            print 'hour %d > %d'  % (self.hour, other.hour)
            return 1
        if self.hour < other.hour:
            print 'hour %d < %d'  % (self.hour, other.hour)
            return -1
        if self.min > other.min:
            print 'min %d > %d'  % (self.min, other.min)
            return 1
        if self.min < other.min:
            print 'min %d < %d'  % (self.min, other.min)
            return -1
        if self.sec > other.sec:
            print 'sec %d > %d'  % (self.sec, other.sec)
            return 1
        if self.sec < other.sec:
            print 'sec %d < %d'  % (self.sec, other.sec)
            return -1

    def date_eq(self, other):
        if self.year != other.year:
            return False
        if self.mon != other.mon:
            return False
        if self.day != other.day:
            return False
 
        return True


class aws_monitor(ec2_connection):
    def __init__(self, id, key, region):
        try:
            super(aws_monitor, self).__init__(id, key, region)
        except region_error:
            raise region_config_error

    def get_instance(self, instance_id):
        id_list = [instance_id]
        try:
            nodes = self.list_nodes(ex_node_ids = id_list)
        except key_error:
            raise access_config_error
        except instance_id_invalid:
            raise instance_config_error
        if len(nodes) == 0:
            print 'get instance %s failed' % instance_id
            return 'None'

        node = nodes[0]
        instance = instance_info(node.id, node.extra['status'], 
                node.public_ips, node)

        return instance

    def start_instance(self, instance):
        return start_node(self, instance.info)

    def stop_instance(self, instance):
        return stop_node(self, instance.info)


class cloud_monitor(object):
    def __init__(self, name, cloud_type, id, key, region):
        self.name = name
        handler = cloud_handler[cloud_type]
        self.handler = handler(id, key, region)
        self.scale = {}
        self.watch = {}
        self.timer = {}
        self.scaled_time = {}

    def get_instance(self, instance_id):
        try:
            instance = self.handler.get_instance(instance_id)
        except access_config_error:
            print 'access key invalid'
            #call notifier
            return 'None'
        except instance_config_error:
            print 'instance id %s invalid' % instance_id
            #call notifier
            return 'None'

        return instance

    def add_instance(self, instance_id, group):
        instance = self.get_instance(instance_id)
        if instance == 'None':
            return False

        group[instance_id] = instance
        return True

    def add_scale_instance(self, instance_id):
        ret = self.add_instance(instance_id, self.scale)
        if ret == False:
            return False

        self.watch[instance_id] = self.scale[instance_id]
        return True

    def add_no_scale_instance(self, instance_id):
        return self.add_instance(instance_id, self.watch)

    def start_instance(self, instance):
        return self.handler.start_instance(instance)

    def stop_instance(self, instance):
        return self.handler.stop_instance(instance)

    def set_scale_time(self, up_time, down_time):
        self.timer['up'] = up_time
        self.timer['down'] = down_time
    

class base_config(object):
    def __init__(self, tag_name, unique = 1, essential = 1, child_parser = {}):
        self.tag_name = tag_name
        self.unique = unique
        self.essential = essential
        self.child_parser = child_parser
        self.value = 'None' 
        self.config = {}

    def get_config(self, conf):
        if conf.nodeName != self.tag_name:
            print 'node name %s is not %s' % (conf.nodeName, self.tag_name)
            return False
        if len(conf.childNodes) == 1:
            self.value = conf.childNodes[0].nodeValue

        for node in conf.childNodes:
            if node.nodeName == '#text':
                continue

            if node.nodeName == '#comment':
                continue

            if node.nodeName not in self.child_parser:
                print 'unkonw directive %s' % (node.nodeName)
                return False
            child_parser = self.child_parser[node.nodeName];
            child = child_parser(node.nodeName)
            ret = child.parse(node)
            if ret == False:
                return False

            if node.nodeName in self.config:
                if child.unique:
                    print 'duplicate directive %s' % node.nodeName 
                    return False
                self.config[node.nodeName].append(child)
            else:
                config_list = []
                config_list.append(child)
                self.config[node.nodeName] = config_list

        for parser_key in self.child_parser.keys():
            child_parser = self.child_parser[parser_key]
            parser = child_parser(parser_key)
            if parser.essential and parser_key not in self.config:
                print 'missing %s in %s' %(parser_key, self.tag_name)
                return False

        return True

    def parse(self, root):
        return self.get_config(root)

    def apply(self):
        for config_key in self.config.keys():
            lists = self.config[config_key]
            for config in lists:
                config.apply()


class monitor_name(base_config):
    pass


class monitor_status(base_config):
    def parse(self, root):
        ret = self.get_config(root)
        if ret == False: 
            return False
        if self.value != 'enable' and self.value != 'disable': 
            print 'monitor status %s is invalid' % self.value
            return False
        return True

class cloud_type(base_config):
    def parse(self, root):
        ret = self.get_config(root)
        if ret == False: 
            return False
        if self.value not in cloud_handler: 
            print 'unkonw %s %s' % (self.tag_name, self.value)
            return False
        return True

class key_id(base_config):
    pass

class secret_key(base_config):
    pass

class cloud_region(base_config):
    pass


class monitor_access(base_config):
    def __init__(self, tag_name):
        child_parser = {cloud_type_tag_name:cloud_type, key_id_tag_name:key_id, 
                secret_key_tag_name:secret_key, region_tag_name:cloud_region}
        super(monitor_access, self).__init__(tag_name, 
                child_parser = child_parser)
    def parse(self, root):
        return self.get_config(root)


class year_config(base_config):
    def __init__(self, tag_name):
        super(year_config, self).__init__(tag_name, essential = 0)
 
    def parse(self, root):
        ret = self.get_config(root)
        if ret == False:
            return False

        curr_time = time.localtime()
        config_year = string.atoi(self.value)

        if (config_year % 4 == 0 and config_year % 100 != 0) \
                or config_year % 400 == 0:
            month_day[1] = 29
        else:
            month_day[1] = 28

        self.value = config_year

        return True


class month_config(base_config):
    def __init__(self, tag_name):
        super(month_config, self).__init__(tag_name, essential = 0)
 
    def parse(self, root):
        ret = self.get_config(root)
        if ret == False:
            return False
        self.value = string.atoi(self.value)
        if self.value < 1 or self.value > 12:
            print 'month %d invalid' % self.value
            return False

        return True

class day_config(base_config):
    def __init__(self, tag_name):
        super(day_config, self).__init__(tag_name, essential = 0)
 
    def parse(self, root):
        ret = self.get_config(root)
        if ret == False:
            return False
        self.value = string.atoi(self.value)
        if self.value < 1 or self.value > 31:
            print 'day %d invalid' % self.value
            return False

        return True
 

class date_config(base_config):
    def __init__(self, tag_name):
        child_parser = {year_tag_name:year_config, month_tag_name:month_config,
                day_tag_name:day_config}
        super(date_config, self).__init__(tag_name, 
                child_parser = child_parser)
    def parse(self, root):
        ret = self.get_config(root)
        if ret == False:
            return False

        if self.value == daily_config:
            return True

        try:
            self.year = self.config[year_tag_name][0].value
        except KeyError:
            print 'missing %s' % year_tag_name
            return False
        try:
            self.mon = self.config[month_tag_name][0].value
        except KeyError:
            print 'missing %s' % month_tag_name
            return False
        try:
            self.day = self.config[day_tag_name][0].value
        except KeyError:
            print 'missing %s' % day_tag_name
            return False

        if self.day > month_day[self.mon - 1]:
            print '%d-%d-%d not exist' %(self.year, self.mon, self.day)
            return False

        return True


class hour_config(base_config):
    def parse(self, root):
        ret = self.get_config(root)
        if ret == False:
            return False
        self.value = string.atoi(self.value)
        if self.value < 0 or self.value > 23:
            print '%s invalid %d' % (self.tag_name, self.value)
            return False

        return True

class minute_second_config(base_config):
    def parse(self, root):
        ret = self.get_config(root)
        if ret == False:
            return False
        self.value = string.atoi(self.value)
        if self.value < 0 or self.value > 59:
            print '%s invalid %d' % (self.tag_name, self.value)
            return False

        return True


class moment_config(base_config):
    def __init__(self, tag_name):
        child_parser = {hour_tag_name:hour_config, 
                minute_tag_name:minute_second_config, 
                second_tag_name:minute_second_config}
        super(moment_config, self).__init__(tag_name, 
                child_parser = child_parser)

    def parse(self, root):
        ret = self.get_config(root)
        if ret == False:
            return False

        self.hour = self.config[hour_tag_name][0].value
        self.min = self.config[minute_tag_name][0].value
        self.sec = self.config[second_tag_name][0].value

        return True
 
class time_config(base_config):
    def __init__(self, tag_name):
        child_parser = {date_tag_name:date_config, time_tag_name:moment_config}
        super(time_config, self).__init__(tag_name, 
                child_parser = child_parser)
    def parse(self, root):
        ret = self.get_config(root)
        if ret == False:
            return False

        date = self.config[date_tag_name][0]
        moment = self.config[time_tag_name][0]

        if date.value == daily_config:
            s_time = scale_time(day = date.value, hour = moment.hour, 
                    min = moment.min, sec = moment.sec)
        else:
            s_time = scale_time(year = date.year, mon = date.mon, 
                    day = date.value, hour = moment.hour, 
                    min = moment.min, sec = moment.sec)

        self.scale_time = s_time

        return True

class instance_config(base_config):
    def __init__(self, tag_name):
        super(instance_config, self).__init__(tag_name, 0, 0)


class scale_config(base_config):
    def __init__(self, tag_name):
        child_parser = {instance_tag_name:instance_config}
        super(scale_config, self).__init__(tag_name, essential = 0, 
                child_parser = child_parser)
 

class monitor_config(base_config):
    def __init__(self, tag_name):
        child_parser = {monitor_name_tag_name:monitor_name, monitor_status_tag_name:monitor_status,
                access_key_tag_name:monitor_access, up_time_tag_name:time_config,
                down_time_tag_name:time_config, scale_tag_name:scale_config,
                no_scale_tag_name:scale_config}
        super(monitor_config, self).__init__(tag_name, 0, 0, child_parser)

    def parse(self, root):
        ret = self.get_config(root)
        if ret == False: 
            return False
       
        self.name = self.config[monitor_name_tag_name][0].value
        self.status = self.config[monitor_status_tag_name][0].value

        access_key = self.config[access_key_tag_name][0]
        self.cloud_type = access_key.config[cloud_type_tag_name][0].value
        self.id = access_key.config[key_id_tag_name][0].value
        self.key = access_key.config[secret_key_tag_name][0].value
        self.region = access_key.config[region_tag_name][0].value
        self.up_time = self.config[up_time_tag_name][0]
        self.down_time = self.config[down_time_tag_name][0]

        self.scale = []
        if scale_tag_name in self.config:
            scale = self.config[scale_tag_name][0]
            for instance in scale.config[instance_tag_name]:
                if instance.value not in self.scale:
                    self.scale.append(instance.value)

        self.no_scale = []
        if no_scale_tag_name in self.config:
            no_scale = self.config[no_scale_tag_name][0]
            for instance in no_scale.config[instance_tag_name]:
                if instance.value not in self.no_scale:
                    self.no_scale.append(instance.value)

        if len(self.scale) == 0 and len(self.no_scale) == 0:
            print 'no instance to be monitor'
            return False

        for instance in self.scale:
            if instance in self.no_scale:
                print 'instance %s in scale and in not_scale' % instance
                return False

    def apply(self):
        global monitor_list
        if self.status == 'disable':
            print 'status %s' % self.status
            if self.name in monitor_list:
                del monitor_list[self.name]
            return True

        try:
            monitor = cloud_monitor(self.name, self.cloud_type, self.id, 
                    self.key, self.region)
        except region_config_error:
            #call notifier
            print 'region configuration in %s of %s invalid' % (self.name,
                    self.tag_name)
            if self.name in monitor_list:
                del monitor_list[self.name]

            return False

        for instance_id in self.scale:
            ret = monitor.add_scale_instance(instance_id)
            if ret == False:
                return False
            
        for instance_id in self.no_scale:
            ret = monitor.add_no_scale_instance(instance_id)
            if ret == False:
                return False
            
        up_scale_time = self.up_time.scale_time
        down_scale_time = self.down_time.scale_time
        monitor.set_scale_time(up_scale_time, down_scale_time)

        monitor_list[self.name] = monitor

        return True


class notifier_config(base_config):
    def parse(self, config):
        ret = self.get_config(config)
        if ret == False: 
            return False
        if not os.path.isfile(self.value):
            print 'file %s not exist' % self.value
            return False
        return True


class cloud_config(base_config):
    def __init__(self, conf):
        self.conf = conf
        child_parser = {notifier_tag_name:notifier_config, monitor_tag_name:monitor_config}
        super(cloud_config, self).__init__('cloud_config', child_parser = child_parser)

    def parse(self):
        try:
            dom = xml.dom.minidom.parse(self.conf)
        except IOError:
            print 'can not open file %s' % self.conf
            return False
        except Exception:
            print 'file %s has not valid xml format' % self.conf
            return False

        ret = self.get_config(dom.documentElement)
        if ret == False:
            return False

        self.monitor_name_list = []
        if monitor_tag_name in self.config:
            monitors = self.config[monitor_tag_name]
            for monitor in monitors:
                if monitor.name in self.monitor_name_list:
                    print 'dupilcate monoitor name %s' % monitor.name
                    return False
                self.monitor_name_list.append(monitor.name)

        return True

    def apply(self):
        global notifier
        notifier = self.config[notifier_tag_name][0].value

        global monitor_list
        for monitor_name in monitor_list.keys():
            if monitor_name not in self.monitor_name_list:
                del monitor_list[monitor_name]

        super(cloud_config, self).apply()


class daemon_process(object):
    def __init__(self):
        self.pid_file = '/var/run/cloud_daemon.pid'

    def create_daemon(self):
        if os.path.isfile(self.pid_file):
            print 'cloud daemon is already existed!'
            return False

        try:
            ret = os.fork()
        except OSError:
            print 'fork process failed'
            os._exit(1)
        if ret > 0:
            os._exit(0) #exit father

        # it separates the son from the father
        os.chdir('/')
        os.setsid()
        os.umask(0)

        try:
            pid_file = open(self.pid_file, 'w')
        except IOError:
            print 'create pid file %s failed' % self.pid_file
            return False

        pid = os.getpid()
        try:
            pid_file.write('%d' % pid)
        except IOError:
            print 'create pid file %s failed' % self.pid_file
            return False
        finally:
            pid_file.close()

        return True

    def daemon_exit(self, exit_code):
        os.unlink(self.pid_file)
        exit(exit_code)

    def get_daemon_pid(self):
        try:
            pid_file = open(self.pid_file)
        except IOError:
            print 'can not open pid file %s' % self.pid_file
            return 'None'
        try:
            pid = pid_file.readline()
        except IOError:
            print 'read pid file %s failed' % self.pid_file
            return False
        finally:
            pid_file.close()

        return string.atoi(pid)

    def send_signal(self, sig):
        pid = self.get_daemon_pid()
        if pid == 'None':
            return False

        try:
            ret = os.kill(pid, sig)
        except OSError:
            return False
            
        return True


#Function
def parse_option():
    global config_file, reconfig, quit
    usage = "Usage: %prog <options>"
    parser = optparse.OptionParser(usage = usage)
    parser.add_option("-c", "--config-file", action = "store",
            type = "string", dest = "config_file",
            help = "specify config file",
            default = "None")
    parser.add_option("-r", "--reload", action = "store_true", dest = "reconfig",
            help = "tell daemon reload the configuration file",
            default = False)
    parser.add_option("-q", "--quit", action = "store_true", dest = "quit",
            help = "tell daemon quit at once",
            default = False)
 
 
    (options, args) = parser.parse_args() 
    config_file = options.config_file
    reconfig = options.reconfig
    quit = options.quit

    if config_file == 'None':
        print 'please specify configuration file'
        return False

    ret = re.match('^/', config_file)
    if ret is None:
        config_file = os.getcwd() + '/' + config_file

    return True

def watch_thread(monitor):
    print 'in monitor %s' % monitor_name
    for instance_id in monitor.watch.keys():
        prev_state = monitor.watch[instance_id]
        curr_state = monitor.get_instance(instance_id)

        notify_info = notifier
        if prev_state.ip != curr_state.ip:
            notify_info += ' -i %s %s ' % (prev_state.ip, curr_state.ip)

        if prev_state.status != curr_state.status:
            notify_info += ' -s %s %s ' % (prev_state.status, 
                            curr_state.status)

        if notify_info != notifier:
            print 'state changed, info = %s' % notify_info
            os.system(notify_info)
            monitor.watch[instance_id] = curr_state
        else:
            print 'state not changed'
            print 'instance: id = %s, ip = %s, status = %s' %(curr_state.id, curr_state.ip, curr_state.status)

    if len(monitor.scale) == 0:
        return

    curr_time = scale_time(use_curr = 1)

    for timer_key in monitor.timer.keys():
        if timer_key in monitor.scaled_time:
            scaled_time = monitor.scaled_time[timer_key]
            if scaled_time.date_eq(curr_time):
                print 'has been scaled'
                continue

        timer = monitor.timer[timer_key]
        if curr_time > timer:
            for instance_id in monitor.scale.keys():
                instance = monitor.scale[instance_id]
                if timer_key == 'up':
                    print 'up==========='
                else:
                    print 'down==========='

            monitor.scaled_time[timer_key] = curr_time
        else:
            print 'not time out'

        return


def monitor_loop(monitor_array):
    global notifier

    while True:
        try:
            mutex.acquire()
        except:
            return

        for monitor_name in monitor_list.keys():
            monitor = monitor_list[monitor_name]
            watch_thread(monitor)

        try:
            mutex.release()
        except:
            return
        time.sleep(1)

def reconfig_signal_handler(signum, frame):
    global reconfig
    reconfig = True

def quit_signal_handler(signum, frame):
    global quit
    quit = True


cloud_handler = {'aws':aws_monitor}

#main
if __name__ == '__main__':
    ret = parse_option()
    if ret != True:
        exit(1)

    config = cloud_config(config_file)
    ret = config.parse()
    if ret == False:
        exit(1)

    proc = daemon_process()

    if reconfig:
        ret = proc.send_signal(signal.SIGUSR1)
        if ret == False:
           exit(1)
        exit(0)

    if quit:
        ret = proc.send_signal(signal.SIGUSR2)
        print 'cloud daemon quit!'
        if ret == False:
           exit(1)
        exit(0)

    ret = proc.create_daemon()
    if ret == False:
        exit(1)

    signal.signal(signal.SIGUSR1, reconfig_signal_handler)
    signal.signal(signal.SIGUSR2, quit_signal_handler)

    config.apply()

    thread = threading.Thread(target = monitor_loop, args = (monitor_list, ))
    thread.setDaemon(True)
    thread.start()

    while True:
        print 'before sleep'
        print monitor_list.keys()

        signal.pause()
        print 'after sleep'

        if reconfig:
            reconfig = False
            print 'reconfig'
            config = cloud_config(config_file)
            ret = config.parse()
            mutex.acquire()
            if ret == True:
                config.apply()
            else:
                #monitor_list = {}
                for monitor_name in monitor_list.keys():
                    del monitor_list[monitor_name]

            mutex.release()

        if quit:
            mutex.acquire()
            for monitor_name in monitor_list.keys():
                del monitor_list[monitor_name]
            mutex.release()

            proc.daemon_exit(0)
