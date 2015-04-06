#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>

#undef REQUIRE_PLUGIN
#include <stamm>
#include <updater>

#define UPDATE_URL    "http://bitbucket.toastdev.de/sourcemod-plugins/raw/master/GrapplingHook-Stamm.txt"

#pragma semicolon 1

public Plugin myinfo =
{
	name = "Stamm: Grappling Hook Premium",
	author = "Toast",
	description = "Allow grappling hook for stamm players only",
	version = "0.0.2",
	url = "bitbucket.toastdev.de/sourcemod-plugins"
}

ConVar g_cGrapplingHook = null;

bool g_bDebug = false;

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
	if ((buttons & IN_ATTACK) == IN_ATTACK) 
    {  	
		char classname[64];
		GetClientWeapon(p_iClient, classname, 64);
	   
		if(StrEqual(classname, "tf_weapon_grapplinghook"))
	    {
			if(IsClientInGame(p_iClient) && STAMM_IsClientValid(p_iClient))
	      	{
	      	
				if(g_bDebug)
				{
					PrintToChatAll("[Grappling Hook Premium - Debug] Somone tries to use Grappling Hook! Player: %N", p_iClient);	
				}
				
				int p_iBlock = STAMM_GetBlockOfName("ghaccess");
	      		
				if(STAMM_HaveClientFeature(p_iClient, p_iBlock))
				{
					if(g_bDebug)
					{
						PrintToChatAll("[Grappling Hook Premium - Debug] Access granted");	
					}
					
					return Plugin_Continue;
				}
				
				if(g_bDebug)
			  	{
				 	PrintToChatAll("[Grappling Hook Premium - Debug] Access denied");	
				}
				buttons &= ~IN_ATTACK;
				 
				return Plugin_Changed;			    	
			}
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