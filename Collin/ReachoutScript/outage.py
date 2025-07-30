import pyperclip

def outage() -> None:
    s1: str = input('drive letter- ')
    s2: str = f'Hey the outage with the {s1.capitalize()} drive has been resolved can you confirm you have access to it again?'
    pyperclip.copy(s2)
    return
outage()
