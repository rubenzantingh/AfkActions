# AfkActions

## Description
Tired of the same old `/sit` animation whenever you go AFK in World of Warcraft? This addon lets you customize the default AFK functionality, 
enabling actions like performing animations or sending messages when you go AFK or return.

## Download
The [Curseforge Client](https://curseforge.overwolf.com/) can be used to find and download this addon once it has been listed. 
It can also be found on its [Curseforge page](https://www.curseforge.com/wow/addons/afkactions).

If you prefer to download the addon manually, you can do so by visiting the releases page, selecting your preferred version, and placing it in your addons folder.

## Contribution
Feedback is always welcome, regardless of the addon's current state. You can send your suggestions to me on GitHub or by leaving a comment on CurseForge. 
For technical suggestions, you can also submit a Pull Request on GitHub or open an issue.

## Donation
If you would like to support the development of the AfkActions addon by donating, you can do so via PayPal:

<a href="https://www.paypal.com/donate/?hosted_button_id=PHALZJR7LT7FG" rel="nofollow"><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif"/></a>

## Features

Several options were added to the addon configuration tab within the game. Additionally, the command `/goafk` was added in order to make several features work. 
For this command, the addon should automatically register a new macro that can be used from the action bar. 

### Perform actions
Two input fields were registered that can be filled with actions that are performed when going AFK or when coming back. Currently, the following actions are available (more in the future):

| Key   | Description                                                                    |
|-------|--------------------------------------------------------------------------------|
| EMOTE | Executes an emote                                                              |
| WAIT  | Pauses for a specified number of milliseconds before executing the next action |

#### How to define actions
Each action in the input field must be enclosed in square brackets (`[]`) and should include:

1. **Action Type** (e.g., `EMOTE` or `WAIT`),
2. A **comma** (`,`), and
3. The **value** for that action (e.g., the emote name or the wait duration in milliseconds).

Separate multiple actions with a comma (`,`). See the examples below for reference:

**Perform a single action:**

``[EMOTE,SLEEP]``

**Perform multiple sequential actions:**

``[EMOTE,WAVE],[EMOTE,SLEEP]``

**Add a delay between actions:**

``[EMOTE,SIT],[WAIT,5000],[EMOTE,SLEEP]``

Please that each emote behaves differently, and you might have to tweak your action list a bit in order for it to work as you intend. Some emotes, like SLEEP, also disable follow up emotes.
If you notice other strange behaviour, make sure to send a message.

### Send messages
Using the registered `/goafk` command it is possible to send a custom message to one of the following channels indicating that you are AFK:

1. Say
2. Party
3. Raid
4. Guild

When coming back from being AFK it is also possible to send a custom message to one of the following channels indicating that you are back:

1. Party
2. Raid
3. Guild

### Customize AFK reply message
You can normally set this message by typing `/afk Custom message`. 
By using the new input field in combination with the `/goafk` command you can now standardize this message instead of having to type it every time.  




