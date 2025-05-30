local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,114514)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--P1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(s.rmlimit)
	c:RegisterEffect(e1)
	--P2 pendulum set
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
	--M1
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- M1 2
local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o*10) -- 注意别和别的效果冲突
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
	--M2 search
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,id+o*2)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
--P1
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsOnField() and c:IsCode(13331639) and c:IsFaceup()
		and r&REASON_EFFECT~=0 and re:GetOwnerPlayer()~=tp
end
--P2
function s.penfilter(c)
	return c:IsSetCard(0x10f8) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
--M1
--table
local code_list={39915560,51570882,41209827,14513273,76794549,12289247,48461764,76840111,92428405,84343351,59765225,50954680,82044279,82044279,82044279,82044279,02254222,11067666,30095833,01621413,6427652,16195942,28781003,75672051,88504133,13486638,72378359,01516510,88305705,14105623,16178681,49684352}
--
function s.spcfilter(c)
	return c:IsSetCard(0x10f2,0x2073,0x2017,0x1046) and not c:IsPublic()
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,nil)
	if #g==0 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=g:Select(tp,1,4,nil)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)
	return true
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
end

function s.lvfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER)
		and not c:IsCode(114514)
		and c:IsAbleToGrave()
		and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_DECK)
			 or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
		and c:IsCode(table.unpack(code_list))
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		e:SetLabelObject(g:GetFirst())
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	end
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=e:GetLabelObject()
	if tg and Duel.SendtoGrave(tg,REASON_EFFECT)>0 and tg:IsLocation(LOCATION_GRAVE) then
		local lv=tg:GetLevel()
		if lv>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end

--M2
function s.thfilter(c)
	return aux.IsCodeListed(c,13331639) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end