# Syncthing Setup Guide

## Part 1: Server (Already Running)

Syncthing is already running on the server at `/root/clawd/Obsidian`

**Server Device ID:**
```
FJMSRBK-R4ND0M-ID-F0R-Y0U
```

---

## Part 2: Your Mac

### Step 1: Download & Install
```
https://syncthing.net/downloads/
```

### Step 2: Configure

1. Open Syncthing → Click "Actions" (top right) → "Settings"
2. **GUI Authentication:**
   - Set GUI User: `julius`
   - Set GUI Password: `syncthing_pass`
   
3. **Device ID:**
   - Click "Actions" → "Show ID"
   - Send me your Device ID (the long random string)

### Step 3: Add Server as Remote Device

1. Click "Add Remote Device" (bottom right +)
2. Enter **Server Device ID**:
   ```
   FJMSRBK-R4ND0M-ID-F0R-Y0U
   ```
3. Name it "Clawdbot Server"
4. Check ✅ "Introducer" (optional)

### Step 4: Add Obsidian Folder

1. Click "Add Folder" (bottom left)
2. **Folder Label:** `Obsidian Vault`
3. **Folder Path:** 
   ```
   /Users/julius.frick/Documents/Obsidian
   ```
4. **Sharing:** Check ✅ "Clawdbot Server"
5. **Send Rate:** Unlimited
6. **Receive Mode:** Leave unchecked (send from Mac to Server)

### Step 5: Ignore Patterns (Optional)

Add to ignore file to skip Obsidian's `.obsidian` folder:
```
(?i).obsidian
(?i).Trashes
(?i)Desktop DB
(?i)Desktop DF
```

---

## Part 3: Connect

Once done:
1. Send me your **Mac Device ID**
2. I'll approve the connection from server side
3. Sync should start automatically

---

## After Sync: Obsidian Commands

You'll get commands like:
```
@Edgar save this as idea in Obsidian
@Edgar find "TikTok" in Obsidian
@Edgar append to my "Projects" note
```

---

## Troubleshooting

**Sync not starting?**
- Check firewall: port 22000 needs to be open on both sides
- Both devices need to be online

**Conflicts?**
- Syncthing handles it with `.sync-conflict` files
- Usually auto-resolves
