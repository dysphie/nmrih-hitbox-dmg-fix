#include <dhooks>

int offs_hitbox;

public Plugin myinfo = {
    name        = "[NMRiH] Hitbox Damage Fix",
    author      = "",
    description = "Fixes armor absorption on NG soldiers and head splits not working as intended",
    version     = "1.0.0",
    url         = "https://github.com/dysphie/nmrih-hitbox-dmg-fix"
};

public void OnPluginStart()
{
	char version[7];
	
	ConVar cvVersion = FindConVar("nmrih_version");
	if (cvVersion)
		cvVersion.GetString(version, sizeof(version));
	
	if (!StrEqual(version, "1.12.1"))
		SetFailState("Unsupported game version");

	GameData gamedata = new GameData("hitboxfix.games");

	offs_hitbox = gamedata.GetOffset("CTakeDamageInfo::hitbox");
	if (offs_hitbox == -1)
		SetFailState("Failed to get offset CTakeDamageInfo::hitbox");

	DynamicDetour detour = DynamicDetour.FromConf(gamedata, "CNMRiH_BaseZombie::TraceAttack");
	if (!detour)
		SetFailState("Couldn't detour CNMRiH_BaseZombie::TraceAttack");
	detour.Enable(Hook_Pre, Detour_TraceAttack);

	delete detour;
	delete gamedata;
}

MRESReturn Detour_TraceAttack(DHookParam params)
{
	int hitbox = params.GetObjectVar(3, offs_hitbox, ObjectValueType_Int);

	if (hitbox < 0 || hitbox > 16)
		return MRES_Ignored;

	hitbox++;
	if (hitbox == 16)
		hitbox = 0;

	params.SetObjectVar(3, offs_hitbox, ObjectValueType_Int, hitbox);
	return MRES_ChangedHandled;
}