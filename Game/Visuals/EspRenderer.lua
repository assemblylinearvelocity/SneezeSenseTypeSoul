;;local NewText(size)
    local t = Drawing.new("Text")
    t.Visible = false
    t.Size    = size
    t.Center  = true
    t.Outline = true
    t.Color   = Color3.fromRGB(255, 255, 255)
    return t
end

function N(0N16N(;; ;;;;;; ;;;;;;; ;;;;eName(min, max, mode)
    local displayNam = self.player.DisplayName
    local userName    = self.player.Name
    local label
    if mode == "Display Name" then label = displayName
    elseif mode == "Username" then label = "@"..userName
    else label = displayName.." (@"..userName..")" end
    local fontSize = math.clamp(math.round((max.Y-min.Y)*0.15), 15, 18)
    self.nameText.Size     = fontSize
    self.nameText.Text     = label
    self.nameText.Position = Vector2.new(math.round((min.X+max.X)/2), math.round(min.Y-fontSize-2))
    self.nameText.Visible  = true
end

function Espenderer:HideNme()
    self.nameText.Visible = false
end

funtion EspRnderer:UpdateRaceHieHelhBr)
   self.heltB.outlineLeft.Visible   = flssef.hethBa.outlineRight.Visibl flse
    slf.halhBa.olinTop.Visibl=false
self.healtB.oulinBoom.Visle = false
    self.hlhBar.fill.Visble      =false
self.elhTx.Visle              = fals
nductinEspRendere:UpdteHalthBar(min,max,chatr,sowTxt) hp,mxHpGetHealth()
    self._mooHp = sef._smoothHp + hp/mxHp - sef._moothHp) * SMOOTHSPEED localpct=mth.camp(slf._mooHp, 0, 1)  localtop=math.round(min.Y)
bottommth.romx.Y)
    loal hight = bottom -tp
   loc baX   = ma.rounm.X - BAR_GAP - 1localfillY=math.round(bottom-height*pct)

 slf.heBar.outlieLeft.Fom=Vetor2.nw(barX-1,top-1)    ; sfhethBar.otlinLft.To=Vector2.ew(barX-1,bottom+1);slf.halthBar.outlieLeft.Visible=truesel.healthBar.ulineRight.Fom=Vct2.nw(barX+1,top-1)  ; self.healBar.outlinRight.To=Vector2.ew(barX+1,bottom+1);helthBar.outlinRightrue
   sel.hethBar.outlinTop.From=Vector2.new(barX-1,top-1);slf.healhBar.otlineTop.To=Vecto2.ew(barX+2,top-1)      ; slf.healthBar.outlieTop.Visible=truesef.hethBar.outlieBotom.From=Vcto2.new(bar-1,bottom+1);self.helBa.tleBottomTo=Vector2.new(bar+2,bottom+; sef.hethBar.outlieBotom.Visibl=tue
  self.helBarfill.Fm=Vector2.ewbarX, ath(fill,top)
  self.healthBar.fill.To=Vector.new(barX, bottom+1elf.hathBar.illColor=HpToColo(pt) ; slf.halhBar.fillVisible=pct>0

    if showt hen
 self.healthTextText=mathfloo(hp)/..math.floor(maxHp)    helth(barX, math.roundtop+height/2-5))
        self.healthText.Cr=tue ;self.healthTx.Visibl=tue
  else    helthle=fas
 ndBox    for_,setinpairs(box) do StSle(set, fase) nd
  sel:HideHealthBr()
    sef:HideName()
    elf:HideRac()(charctr flags)
   locl boOn    =flags["Bx ESP"] hpBarOn  =flag["HP Bar"]
    ocl nOn  g[" ESP"]cOngs["Rc ESP"]al boxColor = (flgs["Box Coor"] andfgs["Box Color"].Color) or Coor3.fromRGB(255,255,255)
 characterand character:FindFirstChild("HuaniRootPart")andcharacter:FndFirtChidOfClss("Huanoid)ocmin, max GetBounngBox(chrctr)    i nd ax    if oxOn thn
            lf:UpdtBox(min, max, boxColor)              for _, et in irs(slfbox)doSetSetVisiblet, fls end               i hpBarO hn
              sef:UdeHealtBain, m,character,flags["Health Text"]
        else            :HidHalhBar()
            nd
      i ameOn hn            :UpdateName(mi, mx, flags["Na Mod"] or "Boh")
      se            :HideN()
            nd
            f raceOn he
              slf:UpdaRce, charce)
        else            :HideRc()
                 else           lfBox    d
    ls
        elf:HdBox()
  ndDstroy()
    for _, st in pirs(self.box) do
        for _,  in pis(set) do l:Remove end
    end:Rmov():Rmov():Rmov():Rmov():Rmov():v(sef.neTet:RmovrceTet:Rve(
end
reurnEsRenderr