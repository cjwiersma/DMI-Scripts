import pyperclip


def weeeeee() -> None:
    l: str = input('Name - ')
    l2: str = input('Proxy - ')
    l3: str = f'Hello {l.capitalize()} I enabled send as access to the {l2} for you. Can you send me a test email from the {l2}.'
    pyperclip.copy(l3)
    return

weeeeee()

