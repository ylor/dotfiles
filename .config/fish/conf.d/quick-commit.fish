function quick-commit
    git add -A && git commit -m $(curl --silent --fail https://whatthecommit.com/index.txt) && git push
end
