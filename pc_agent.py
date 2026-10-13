import asyncio, json, os, platform, psutil, pyautogui, websockets

PIN = "1234"
PORT = 8765
pyautogui.FAILSAFE = False

async def handler(ws):
    async for msg in ws:
        req = json.loads(msg)
        if req.get("auth") != PIN:
            continue
        act = req.get("action")
        d = req.get("data", {})
        if act == "mouse_move":
            pyautogui.moveRel(d.get("dx", 0), d.get("dy", 0), _pause=False)
        elif act == "click":
            pyautogui.click(button=d.get("btn", "left"))
        elif act == "text":
            pyautogui.write(d.get("val", ""), interval=0.01)
        elif act == "kill":
            psutil.Process(int(d.get("pid"))).terminate()

async def main():
    async with websockets.serve(handler, "0.0.0.0", PORT):
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
