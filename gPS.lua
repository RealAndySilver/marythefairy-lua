--gPS lite by jStrahan ©2011
  local ooeoceoe={};local oocooooo=display.newGroup();local cogqpcoq=string.sub
local oocopooc=math.min;local qqpcoopc=string.char;local oocopooo=math.max
 local pboocgqp=52;ooeoceoe.ogpcggoo=function(oqpoggpc,oqpoggoo)
transition.to(oqpoggpc,{time=oqpoggoo.ccoccoco,x=(oqpoggoo.copqpocc*oqpoggoo.oqpocooo)+(oqpoggoo.cqpcqcco+oqpoggoo.cqpoqoco),
  y=(oqpoggoo.copqpoco*oqpoggoo.oqpocooo)+(oqpoggoo.cqpoqcco+oqpoggoo.cqpoqooo),xScale=oqpoggoo.coccpcoo,yScale=oqpoggoo.coccpcco,
 alpha=oqpoggoo.coocqcco,transition=oqpoggoo.oqpooooo,onComplete=function() cqpoogoo={};cqpoogoo.scale={oqpoggoo.coccpcoo,oqpoggoo.coccpcco}
cqpoogoo.alpha=oqpoggoo.coocqcco;cqpoogoo.pos={oqpoggpc.x,oqpoggpc.y,oqpoggoo.oqpoqooo,oqpoggoo.oqpocooo,oqpoggoo.oqpooooo}
   cqpoogoo.info={group=oqpoggoo.oqpooqpo,max=oqpoggoo.oqpooqpc};if type(oqpoggoo.cocopooo)=="function" then
 oqpoggoo.cocopooo(cqpoogoo) end;if oqpoggpc then oqpoggpc:removeSelf(); oqpoggpc=nil end;oqpoggoo=nil;end})end
  ooeoceoe.cgpoogoo=function(oqpoggoo) oqpoggoo.imgStart.size=oqpoggoo.imgStart.size or {};local oooccopo="gPS"
 oqpoggoo.imgStart.scale=oqpoggoo.imgStart.scale or {};oqpoggoo.imgStart.pos=oqpoggoo.imgStart.pos or {};local gggoqpoc=0.01
oqpoggoo.imgEnd.scale=oqpoggoo.imgEnd.scale	or {};oqpoggoo.imgEnd.pos=oqpoggoo.imgEnd.pos or {};oocoococ = {};local pocqpgoo=1000
 oocoococ.ccoccoco=oqpoggoo.imgStart.life or pocqpgoo;oocoococ.cpoopcoo=oqpoggoo.imgStart.size[1]or 10;local pppqpogo=255
  oocoococ.cooopcoo=oqpoggoo.imgStart.size[2]or 10;oocoococ.coopocoo=oqpoggoo.imgStart.scale[1]or 1;local ppgqpgqo=""
 oocoococ.coopooco=oqpoggoo.imgStart.scale[2]or 1;oocoococ.coqpooco=oocopooo(gggoqpoc,oqpoggoo.imgStart.alpha)or 1;local ooqpcogo=4
oocoococ.ccqpoooo=oocopooc(pppqpogo,oocopooo(0,oqpoggoo.imgStart.color[1]or pppqpogo))or pppqpogo;oocoococ.ooqpoooo=oocopooc(pppqpogo,oocopooo(0,oqpoggoo.imgStart.color[2]or pppqpogo))or pppqpogo
 oocoococ.ooqpoooc=oocopooc(pppqpogo,oocopooo(0,oqpoggoo.imgStart.color[3]or pppqpogo))or pppqpogo;oocoococ.ooqpoocc=oocopooc(pppqpogo,oocopooo(0,oqpoggoo.imgStart.color[4]or pppqpogo))or pppqpogo
  oocoococ.oooqpocc=oocopooo(0,oqpoggoo.imgStart.stroke[1]or 1)or 1;oocoococ.oooqpccc=oocopooo(0,oqpoggoo.imgStart.stroke[2]or pppqpogo)or pppqpogo
oocoococ.oocqpocc=oocopooo(0,oqpoggoo.imgStart.stroke[3]or pppqpogo)or pppqpogo;oocoococ.occqpocc=oocopooo(0,oqpoggoo.imgStart.stroke[4]or pppqpogo)or pppqpogo		
 oocoococ.copqpocc=oqpoggoo.imgStart.pos[1]or 160;oocoococ.copqpoco=oqpoggoo.imgStart.pos[2]or 240;oocoococ.copqpooo=oqpoggoo.imgStart.pos[3]or 0
oocoococ.copopooo=oqpoggoo.imgStart.pos[4]or 0;oocoococ.cocoqooo=oqpoggoo.imgStart.pos[5]or 0;oocoococ.cocopooo=oqpoggoo.imgEnd.onComplete or nil
  oocoococ.coccpcoo=oocopooo(gggoqpoc,oqpoggoo.imgEnd.scale[1])or 1;oocoococ.coccpcco=oocopooo(gggoqpoc,oqpoggoo.imgEnd.scale[2])or 1
oocoococ.coocqcco=oocopooo(gggoqpoc,oqpoggoo.imgEnd.alpha)or gggoqpoc;oocoococ.cqpcqcco=oqpoggoo.imgEnd.pos[1]or 160;oocoococ.cqpoqcco=oqpoggoo.imgEnd.pos[2]or 480
 oocoococ.cqpoqoco=oqpoggoo.imgEnd.pos[3]or 0;oocoococ.cqpoqooo=oqpoggoo.imgEnd.pos[4] or 0;oocoococ.oqpoqooo=oqpoggoo.imgEnd.pos[5]or 0
  oocoococ.oqpocooo=oqpoggoo.imgEnd.pos.ogpcggoo or 1;oocoococ.oqpooooo=oqpoggoo.imgEnd.pos.ease or easing.linear
 oocoococ.oqpoooqp=oqpoggoo.imgInfo.text or oooccopo;oocoococ.oqpoooqp=cogqpcoq(oocoococ.oqpoooqp,1,qqpcoopc(pboocgqp))or ppgqpgqo
oocoococ.oqpooqpo=oqpoggoo.imgInfo.group or oocooooo;oocoococ.oqpooqpc=oocopooc(oqpoggoo.imgInfo.max, pocqpgoo)or 100
 oocoococ.oqpcoqpc=oqpoggoo.imgInfo.image or nil;oocoococ.oqpcgqpc=nil;return oocoococ;end;ooeoceoe.newCircle=function(oqpoggoo) local ogpoogoo={};ogpoogoo=ooeoceoe.cgpoogoo(oqpoggoo)
function ogpoogoo:ogooogoo() local ogpoggoo={};ogpoggoo=display.newCircle(self.oqpooqpo,-600,-600,(self.cpoopcoo+self.cooopcoo)/2)
   ogpoggoo:setReferencePoint(display.CenterReferencePoint);ogpoggoo:setFillColor(self.ccqpoooo,self.ooqpoooo,self.ooqpoooc,self.ooqpoocc)
 ogpoggoo.strokeWidth=self.oooqpocc;ogpoggoo:setStrokeColor(self.oooqpccc,self.oocqpocc,self.occqpocc);ogpoggoo.xScale=self.coopocoo
  ogpoggoo.yScale=self.coopooco;ogpoggoo.x=self.copqpocc+self.copqpooo;ogpoggoo.y=self.copqpoco+self.copopooo;ogpoggoo.alpha=self.coqpooco
 ooeoceoe.ogpcggoo(ogpoggoo,self) end;if ogpoogoo.oqpooqpo.numChildren<ogpoogoo.oqpooqpc then ogpoogoo:ogooogoo() end end
 ooeoceoe.newText=function(oqpoggoo) local ogpoogoo={};ogpoogoo=ooeoceoe.cgpoogoo(oqpoggoo);function ogpoogoo:ogooogoo()
   local ogpoggoo={};ogpoggoo=display.newText(self.oqpooqpo,self.oqpoooqp,-600,-600,self.oqpcgqpc,(self.cpoopcoo+self.cooopcoo)/2)
 ogpoggoo:setReferencePoint(display.CenterReferencePoint);ogpoggoo:setTextColor(self.ccqpoooo,self.ooqpoooo,self.ooqpoooc,self.ooqpoocc)
ogpoggoo.rotation=self.cocoqooo;ogpoggoo.xScale=self.coopocoo;ogpoggoo.yScale=self.coopooco;ogpoggoo.x=self.copqpocc+self.copqpooo
 ogpoggoo.y=self.copqpoco+self.copopooo;ogpoggoo.alpha=self.coqpooco;ooeoceoe.ogpcggoo(ogpoggoo,self) end
if ogpoogoo.oqpooqpo.numChildren<ogpoogoo.oqpooqpc then ogpoogoo:ogooogoo() end end return ooeoceoe	









