If code needs a paragraph explaining what it does, first try making code clearer.

When you do write a comment, follow these rules:
- Add a comment only when the code does not explain the reason.
- Do not add a comment that repeats the code.
- Write comments in short, plain sentences.

## Example: bad comment
```
i++ // increment i
```

## Example: good comment
```
// retry three times because the network is not reliable
retry(fetchUser, 3)
```
