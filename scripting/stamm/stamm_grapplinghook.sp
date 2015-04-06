#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>

#undef REQUIRE_PLUGIN
#include <stamm>
#include <updater>

#define UPDATE_URL    "http://bitbucket.toastdev.de/sourcemod-plugins/raw/master/GrapplingHook-Stamm.txt"

public Plugin myinfo =
{
	name = "Stamm: Grappling Hook Premium",
	author = "Toast",
	description = "Allow grappling hook for stamm players only",
	version = "0.0.1",
	url = "bitbucket.toastdev.de/sourcemod-plugins"
}

ConVar g_cGrapplingHook = null;

bool g_bDebug = true;

public void OnAllPluginsLoaded()
{
	if (!STAMM_IsAvailable()) 
	{
		SetFailState("Can't Load Feature, Stamm is not installed!");
	}
	STAMM_LoadTranslation();
	
	char Name[32];
	Format(Name, 32, "%T", "Name", LANG_SERVER);
	
	STAMM_RegisterFeature(Name);
}
public STAMM_OnClientRequestFeatureInfo(client, block, &Handle:array)
{
	char description[256];
	Format(description, sizeof(description), "%T", "GrapplingHookDescription", LANG_SERVER);
	
	PushArrayString(array, description);
}
public OnPluginStart()
{
	g_cGrapplingHook = FindConVar("tf_grapplinghook_enable");
	if(g_cGrapplingHook == null)
	{
		SetFailState("Grappling Hook Cvar couldn't be found. (tf_grapplinghook_enable)");
	}
	
	
	HookEvent("player_connect", Event_PlayerConnect_Callback);
	
	
	if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
   }
public APLRes AskPluginLoad2(Handle myself,bool late, char[] error, int err_max)
{
   MarkNativeAsOptional("Updater_AddPlugin");
   return APLRes_Success;
  }
  
public Action OnPlayerRunCmd(int p_iClient, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{ 
	if(g_bDebug)
	{
	  PrintToChatAll("[Grappling Hook Premium - Debug] Somone run cmd! Player: %N", p_iClient);	
	}
	if ((buttons & IN_ATTACK) == IN_ATTACK) 
    {  
			
	    char classname[64];
	    GetClientWeapon(p_iClient, classname, 64);
	    
	    if(g_bDebug)
		{
		  PrintToChatAll("[Grappling Hook Premium - Debug] Somone used a weapon! Player: %N, Weapon: %s", p_iClient, classname);	
		}
	    if(StrEqual(classname, "tf_weapon_grappling_hook")){
	      return Plugin_Stop;
	    }
	}
	return Plugin_Continue;
}  
  
  
public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}
   
   
public Action Event_PlayerConnect_Callback(Handle event, char[] name, bool dontBroadcast)
{
	// Someone joined the game
	int p_iUserid = GetEventInt(event, "userid");
	int p_iClient = GetClientOfUserId(p_iUserid);
	if(IsClientInGame(p_iClient) && STAMM_IsClientValid(p_iClient)){
		int p_iBlock = STAMM_GetBlockOfName("ghaccess");
	
		if(STAMM_HaveClientFeature(p_iClient, p_iBlock)){
			return Plugin_Continue;
		}
		else{
			if(g_bDebug)
			{
				PrintToChatAll("[Grappling Hook Premium] Disabling grappling hook for: %N", p_iClient);	
			}
			SendConVarValue(p_iClient, g_cGrapplingHook, "0");
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
}