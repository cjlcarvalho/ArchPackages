su

echo '"\e[A": history-search-backward' >> /etc/inputrc
echo '"\e[B": history-search-forward' >> /etc/inputrc
echo '"\e[C": forward-char' >> /etc/inputrc
echo '"\e[D": backward-char' >> /etc/inputrc
echo '"\t": menu-complete' >> /etc/inputrc
echo '"\e[Z": menu-complete-backward' >> /etc/inputrc

echo 'if [ -f /etc/bash_completion ]; then' >> /etc/bash.bashrc
echo '. /etc/bash_completion' >> /etc/bash.bashrc
echo 'fi' >> /etc/bash.bashrc