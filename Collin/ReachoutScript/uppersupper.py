import pyperclip

def address() -> None:
    l1: str = input('paste their address here - ')
    pyperclip.copy(l1.upper())
    return

address()