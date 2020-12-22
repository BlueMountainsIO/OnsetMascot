
local timer = 0
local timer2 = 0
local Mascots = {}

AddEvent("OnPackageStart", function()
	local res = LoadPak("Mascot01")

	Delay(100, function()
	
		timer2 = CreateTimer(function()
			for i, v in ipairs(Mascots) do
				v.LastLoc[2] = v.LastLoc[1]
				
				v.LastLoc[1] = GetPlayerActor(v.PlayerId):GetActorLocation()
			end
		end, 300)
		
		timer = CreateTimer(function()

			for i, v in ipairs(Mascots) do

				local mascot_loc = v.Actor:GetActorLocation()
				local player_loc = GetPlayerActor(v.PlayerId):GetActorLocation()
				
				local NewLoc = FMath.VInterpTo(mascot_loc, v.LastLoc[2], 0.016, 2.0)
				local NewRot = UKismetMathLibrary.FindLookAtRotation(mascot_loc, player_loc)

				v.Actor:SetActorRotation(FRotator(0, NewRot.Yaw, 0) - FRotator(0.0, 90.0, 0.0))
				
				if FVector.PointsAreNear(NewLoc, player_loc, 100.0) then

					v.SKComp:GetAnimInstance():ProcessEvent("SetIsMoving", false)

				else
				
					v.Actor:SetActorLocation(NewLoc)
					
					v.SKComp:GetAnimInstance():ProcessEvent("SetIsMoving", true)
					
				end
		    end
		end, 16)
		
    end)
end)

AddEvent("OnPackageStop", function()
	DestroyTimer(timer)
	DestroyTimer(timer2)
	for i, v in ipairs(Mascots) do
		v.Actor:Destroy()
	end
end)

AddEvent("OnPlayerStreamIn", function(player)
    CreateMascot(player)
end)

AddEvent("OnPlayerStreamOut", function(player)
	for i, v in ipairs(Mascots) do
		if v.PlayerId == player then
			v.Actor:Destroy()
			table.remove(Mascots, i)
			break
		end
	end
end)

AddEvent("OnPlayerSpawn", function()
	for i, v in ipairs(Mascots) do
		if v.PlayerId == -1 then
			v.Actor:Destroy()
			table.remove(Mascots, i)
			break
		end
	end
	CreateMascot(-1)
end)

function CreateMascot(player)
	local PlayerActor = GetPlayerActor(player)
	local Location = PlayerActor:GetActorLocation()
	local Rotation = PlayerActor:GetActorRotation()
	
	local MascotActor = GetWorld():SpawnActor(ASkeletalMeshActor.Class(), Location, Rotation)
	local SKComponent = MascotActor:GetSkeletalMeshComponent()
	SKComponent:SetCollisionEnabled(ECollisionEnabled.NoCollision)
	SKComponent:SetSkeletalMesh(USkeletalMesh.LoadFromAsset("/Mascot01/ms02_05_Ghost/SK_Ghost"))
	SKComponent:SetAnimInstanceClass(UClass.LoadFromAsset("/Mascot01/ms02_05_Ghost/SK_Ghost_Skeleton_AnimBlueprint"))
	SKComponent:InitAnim(false)
	local AnimInstance = SKComponent:GetAnimInstance()
	
	AnimInstance:ProcessEvent("SetIsMoving", false)

	local tbl = {
		Actor = MascotActor,
		SKComp = SKComponent,
		PlayerId = player,
		LastLoc = {
			Location,
			Location
		}
	}
	table.insert(Mascots, tbl)
end
