import pyperclip

def wewe() -> None:
    s1: str = input('name - ')
    s2: str = input('item shipped - ')
    age: str = input('Is the ticket aged? (y or n) ')
    if age == 'y':
        s3: str = f'Hello {s1} I have an old ticket about getting {s2} shipped to you. Did it ever arrive?'
        pyperclip.copy(s3)
    elif age == 'n':
        s3: str = f'Hello {s1.capitalize()} I have a ticket about getting {s2} shipped to you. Did it ever arrive?'
        pyperclip.copy(s3)
    s4: str = input('run again? ')
    if s4 == 'y':
        return wewe()
    else:
        return
wewe()
