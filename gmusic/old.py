#!/usr/bin/python
# coding=UTF-8

import urllib2, cookielib, urllib, re, random, sys, json,time, datetime
from BeautifulSoup import BeautifulSoup
import subprocess,os
import hashlib

UA = 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 2.0.50727; .NET CLR 3.0.04506.648; .NET CLR 3.5.21022)'
UA = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.0.10) Gecko/2009042316 Firefox/3.0.10'

class Gmusic:
    def __init__( self ):
        cookiejar = cookielib.FileCookieJar()
        cookiejar = urllib2.HTTPCookieProcessor(cookiejar)
        opener = urllib2.build_opener(cookiejar)
        opener.addheaders = [('User-agent', UA)]
        urllib2.install_opener(opener)
        self.playerkey = 'ecb5abdc586962a6521ffb54d9d731a0'
        self.host = 'http://www.google.cn'
        self.starturl = self.host + '/music/chartlisting?q=chinese_new_songs_cn&cat=song'

    def start(self):
        phblist = self.getPhbList()
        i = 1
        for l in phblist:
            print "%2d  %s" % (i,l[0])
            i = i + 1
               
        while True:
            listid = raw_input('Input your choice[1-%s]: ' % len(phblist) )
            if listid == '':
                listid = 0
                break
            if int(listid) != 0 and int(listid) <= len(phblist):
                listid = int(listid) - 1
                break
            
        while True:
            limit = raw_input('Input music num limit[50]: ')
            if limit == "":
                limit = 50
                break
            if int(limit) != 0:
                limit = int(limit)
                break
        print "Your choise is: %s, %2d" % ( phblist[listid][0], limit)
        self.play(phblist[listid][1], limit)
        
    def play(self,url, limit):
        self.hardlimit = int(limit)
        songlist = self.getMusicList(url)
        
        while True:
            if len(songlist) < self.hardlimit:
                total = len(songlist)
            else:
                total = self.hardlimit
            i = random.randint(0, total-1)
            id, rank, name, artist = songlist[i]
            f = sys.stdout
            f.write("try to get play url ... ")
            f.flush()
            #downurl = self.getDownUrl(id)
            downurl = self.getPlayUrl(id)

            if downurl:
                f.write("\r%3s/%s    [ %s - %s ]    " % (rank, str(total), name, artist))
                f.flush()
                resp = urllib2.urlopen(downurl)
                popen = subprocess.Popen(['/usr/bin/mpg123', '-'], stdout = subprocess.PIPE, stdin = subprocess.PIPE, stderr = subprocess.PIPE)
                if popen.returncode == None:
                    f.write(" playing ... ")
                    f.flush()
                    popen.communicate(resp.read())
                    f.write("\r%3s/%s    [ %s - %s ]" % (rank, str(total), artist, name) + " "*50 + "\n" ) 
                else:
                    f.write(" can't play, code: %s\n" % str(popen.returncode))
            else:
                f.write("error\n")

    def getPhbList(self):
        print "Get phb list now ..."
        resp = urllib2.urlopen(self.starturl)
        #resp = open('menu')
        soup = BeautifulSoup("".join(resp.read()), fromEncoding="UTF-8")
        soup = soup.findAll('a', attrs={'class': 'navigation_panel_chart_item'})
        phblist = []
        for a in soup:
            title = unescape(a.string)
            url = self.host + str(a.attrs[2][1])
            if re.search('cat%3Dsong', url):
                phblist.append([title, url])
        return phblist
    
    def getMusicList(self,url):
        print "Get music list now .."
        resp = urllib2.urlopen(url)
        soup = BeautifulSoup("".join(resp.read()), fromEncoding="UTF-8")
        soup = soup.find('table', attrs={'id': 'pagenavigatortable'})
        soup = soup.tr
        urllist = [url]
        for td in soup:
            if len(td) == 4:
                if td.a:
                    urllist.append('%s%s' % ( self.host, str(td.a.attrs[1][1])))
                    
        musiclist = []
        for url in urllist:
            m = self.parseMusicList(url)
            musiclist.extend(m)
            if len(musiclist) >= self.hardlimit:
                break
        return musiclist

    def parseMusicList(self, url):
        resp = urllib2.urlopen(url)
        soup = BeautifulSoup("".join(resp.readlines()), fromEncoding="UTF-8")
        
        soup = soup.find('table', attrs={'id': 'song_list'})
        songlist = []
        for tr in soup:
            if len(tr) == 21:
                id = tr.contents[1].input.attrs[2][1]
                rank = int(tr.contents[3].contents[0].strip('.'))
                name = tr.contents[5].a.contents[0]
                name = unescape( name ).encode('utf-8')
                name = re.sub("\n", '', name)
                
                if tr.contents[9].a:
                    artist = tr.contents[9].a.contents[0]
                else:
                    artist = tr.contents[9].contents[0]
                artist = unescape(artist).encode('utf-8')
                artist = re.sub("\n", '', artist)
                
                #if not tr.contents[17].a:
                #    next # 不能下载，就不加列表里面了
                songlist.append( [id, rank, name, artist] )
        return songlist
    
    def getPlayUrl(self, id):
        sig = hashlib.md5(self.playerkey + id).hexdigest()
        infourl = 'http://www.google.cn/music/songstreaming?id=%s&client=&output=xml&sig=%s&cad=pl_player' % ( id, sig)
        resp = urllib2.urlopen(infourl)
        soup = BeautifulSoup( "".join(resp.readlines()) )
        try:
            url = soup.results.songstreaming.songurl.string
        except:
            url = ''
        return url
        
    def getDownUrl(self, id):
        try:
            resp = urllib2.urlopen('http://www.google.cn/music/top100/musicdownload?id=%s' % id)
            #resp = urllib2.urlopen('http://www.google.cn/music/songstreaming?id=Sa2ec80ec72990184&client=&output=xml&sig=abfa72eaaef6c00f495cb29cbe4a7b27' % id )
            soup = BeautifulSoup( "".join(resp.readlines()) )
            if len(soup.findAll('a')) > 2:
                url = 'http://www.google.cn%s' % soup.findAll('a')[2].attrs[0][1]
            else:
                print "\n出验证码了，听不了了，等明天吧  :(";
                sys.exit(1)
            resp = urllib2.urlopen(url)
            url = resp.geturl()
        except Exception,e:
            print e
            url = ''
        return url

def unescape(text):
   """Removes HTML or XML character references 
      and entities from a text string.
      keep &amp;, &gt;, &lt; in the source code.
   from Fredrik Lundh
   http://effbot.org/zone/re-sub.htm#unescape-html
   """
   def fixup(m):
      text = m.group(0)
      if text[:2] == "&#":
         # character reference
         try:
            if text[:3] == "&#x":
               return unichr(int(text[3:-1], 16))
            else:
               return unichr(int(text[2:-1]))
         except ValueError:
            print "erreur de valeur"
            pass
      else:
         # named entity
         try:
            if text[1:-1] == "amp":
               text = "&amp;amp;"
            elif text[1:-1] == "gt":
               text = "&amp;gt;"
            elif text[1:-1] == "lt":
               text = "&amp;lt;"
            else:
               print text[1:-1]
               text = unichr(htmlentitydefs.name2codepoint[text[1:-1]])
         except KeyError:
            print "keyerror"
            pass
      return text # leave as is
   return re.sub("&#?\w+;", fixup, text)

#if len(sys.argv) > 2:
#    gmusic = Gmusic()
#    gmusic.start(sys.argv[1], sys.argv[2])
#else:
#    print "usage: %s 'MusicUrl' 'limit'" % sys.argv[0]

gmusic = Gmusic()
gmusic.start()
