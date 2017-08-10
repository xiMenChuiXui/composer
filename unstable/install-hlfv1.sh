ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.11.2
docker tag hyperledger/composer-playground:0.11.2 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� Է�Y �=�r۸����sfy*{N���aj0Lj�LFI��匧��(Y�.�n����P$ѢH/�����W��>������V� %S[�/Jf����4���h4@�P��
)F�4l25yضWo��=��� � ���h�c�1p�?a�,�ţQ��acQ�{�j�VpmG� x�Xr_�o�[���>�l��w�6�MQ6����]���	k����Yաu��=�;�%�jOn���Є��mhEF��"��a9�W% !����0���$�}�2�ԝR�T8,U��Y�T�䲻�g?���_ �Mؒ]�I�u��2Z��]@w��ܰT��1XB�F�n�N(9����H�X�O��X�������2��af�������lv�Vq�`E:F�G<��b�&IU��9m�=h�� �03��Մb��n*̌)�Z&�m��n$���gjӴg��)z5��a��#��"���6J����f.�1KV�-Tg1y�\^��qѯ�a�0M??S_�攙���9&\i�-��m�V���̥w�yH-���b�:�K�uS�դ�r%Q;Dԉ͞JĨX��*Rzvj��a�ɢ���V�h%_�x�^8��em��&5ߙ�K}j~�F<Ԅ�V��#�^��q���x��sx��Y!�N�����9��@�j�[��v�m��n�������/����7��Z��w���G�ݡlõ��/��$���u��1)V��*�Z9%�c>\��%����&�9����Y~���˃9�eO�'�.���u�F��l�#���t�v>|n���A�?���i,�Q�C* ��>�Y��x�5޿�2�bѾ��0a&,x�Ӿ����f� xd0����c@֛��Z���]}�&v� ��v��Zx��`Zj_v0���B�$�Nǰ��*��*P�I�D��⼌.��^�z�M'5C�*���$]14w��{�~GM��m���DdWK{�����W՚!�R:j���mW3A(��`{|�	H��q]hҳ� �\�_��Dx��'�����e�a~�E����9���QT"L�1W��Fi�p��OԴ4�:p_p������c�l,Ơt�	�F�����`+�\�8Łӑ�U5�(k��>D�X���z����M�َa�xI}��Cv���&a!`� ��KJm�wؚ<d����i��5�RG�*��=\����m��{�gA�]M�.;�B'��j��qn�q9�:wc�e��Q��4k� ��Z��+<��� �Q#_Il �` Q��PȘ^�c�09n�	���F��)�U�A�0�'�cL��p�9�y�:摔�}I��� �8�е!�������I�`&�v��9�_]Uw�)�io���頁�p��Jt�>ԠlC`C*tT�bـ�My?���9���6��Q� �9��_R~EC�:�6��w����kD��E7��������$��������׈S-���y=[���������Ж�i�p���0g�ǌ�`�����o��u����e�����jc������n����NJ_�_<���l����iS�c����v�����4ײpHk �ǰ�T:W޻�:�����Y%U�V���t�1��|ˮ���� _mc����DVnFL�s���T��J�WW�f�o�N  ��nC�Gd��n7�E� ��&��:�lxs��F��~>����;�Yz+U�\=��
R�V���	�y��xaC4YM��L&Jﱂ�lZpo���P�ë�$*�x�<������s��xKB��I�Ed��@w{h������,,.��dAG�t�V�d���舯�|g]��f�BOr��,bs���v���ȸ��+��l�������a��O���� .��(�L�q!���u���?��V�3��UG�i 2-�R/�hG�	�W��ֹ7̑�){��m��g��&�s�x���	������?����~3������a���?.L��� l�?k���ޅ:ڃ[��e֏��T��?��z�޴�ށ�`�v�O�� Tm��:���{��$�M�{h;�p���9q��Z�3"��t�����JL���"��U�� (�u�5���������>zL�h�ϫ��)4�ꁐ������� �/�an��7af������/�fV��������*��cD���G8�'��L�8`G�`0�3�ĥ��^}���ޡ؋��Y�1a6̌Jᦖ.t;�G�ݷ?����?/��s�)����������#(�ۥ����
,/�eIL�p��r��F���Qf#��g���}�ל���߈������\��������Z�_����s޹"�<��p]��J��E��+�@)�~�	H��yU�Qȡ9�?���et�qȃ�Q͊���%���Zǰ��]#䊐[�Ƈ�ȭ�n���w�
���K��ֻc�A(�˪SU�cQf|�H��F3Y�IQW�Q�ypm�ш�:���D7�w�2�HW���а��g��^����Ǆi�O��o��:�WHV_���̹���k<j���ƚ���m��0�C���ꅋ�BR*W���YJ<�RQL��>�	 �7���qA�kj;��ML�p
L��=��H���١$���t�,U*b�ZJKU)U%���ԓ�a)W�z��p�/[��}9
��O�H����ٳ�T��{i)Y��4�K��I><ȝIh�1a{�œ2��v��~EJ�ʹ���$ހP.��7�wu6ե),�ϲT�+N�^�|*��T�;��	V3��!l��&^�*@7��;��g�ohn��7E��?��> ����kX�B�?���Ll��o-�������y��WAr��k�`��� �j�P����k 6_o3;G���A���]c�%�4>t���O���o,�[1��b���<^N��{E-�A�����D�7�����}.�[��aXnj��Q����u��������!?<t|E�좰�W�[�@Gԉ^ƫ��gK���ly�|_~C��� �����+�p{����9q������p���F��_�b���|�_|���qs�`^���P�����W*�_��Z+��t���2w��e��>�B,��Y�/'l���g��_l�[�zj��Ƙm8�<ji�p�K�0ZV��s(x��sx�?�����f�_�W����e�<�\2x�0���ڀ<� �� =|�!����s4F@�X�����J��@/�Y?<3�-��ރ)��8�����_s�_]�~ee:�L���a��@���#*So��}6enŸȜ7R�B)o��z�Њ�O����M����[<t�D߄[��`���������6�
��:`���Vb�z
;��X�-���� D7�������:�>|�����?�����?O�??��F�y.��RX��r��╝D"�j$8��ːg!��D�Wd>!$l#�#p�A����������x+��oԟD��Td� Cd��֟�?���֓o�ST��m�rT����[�Bm����o������j��|5Q�-��v���������ѿ��5��㱥:�����e��8�!�a"��'��װ��z�o���X�+�����2��������[������^�o��Zࣿ�
<��#�j�M�6�iЖAG�a&?�r�T�{��F�PG���@��t*�����6������"��e���x��b��N��i�$`K�;J��0�
����(�-�݉ˉ���#AM���>�
D���� ܝ����AJ*Ws�\J�J$��^��R��TJTRmq�K��\Y,�%�^|5lF�١�6�RW;��'��4wy�Hw�\JyT��͊lMJv
�z�p!]��d�XGUUS�b���z��W>�.2�b��S��:�S�����˸'�vy��\d��[èJ����RrO�v:��I��"�78�b?-�N�*q��{=ߛ�9��(�BU�s\��cJ�w���I3J{��'�#{�::I׏����M�v)Uh�p�R�������Ӿ�̓�t\Hy=�(��5.����ɱp.�-�7.�V!�q08>:.;� ���A�ٌ�d/�|��oT��h$��lr�k�R�b[ʦR�/291�uw.�Gl�{Q��F�/�UO��'�F�p\��I����q=��k��@<��͊�
��i���w��x�.4˱S^fۃ��j5�/�<�Dm3=�������vZ,��/�bkG�E���q����Q��:sɞu*��d.�x�[�|wp����!	�ɥ�Ť2��ʽ������`Jd�bA��rG)�>8���SR��F��;�eB8ND:��x:'��~\��T3�ε+�A����FƐLY�
��[y����eF��D��,����{���TL����*	G~�z;�����d���˰��Pc[�a�{�D����e�mx���p�����;�_t��}������?:��'ʲ����Z `'�su�8�鄤>�
��>Z�����d��؆::j3Ln��'5�P���S�$֙
��ǚ��2i�\��t�� �+%�e����jŲY�u/3r*����R���O)�ޭ���P�hP������Nu���a��9Y#�;̧����d�cRO���7۱O=�|�??��������񩻾�'�����Y����ߵ@p��%�Tp��t��d�w�ģ�+$-)飶(��%e�5��yS�8n���oڦ|؋>��R�4S�JPq˧o�z����h�M�� ߽tt����6o��&�o��jNN�����>M٧���A���c������%�X ��8?}�G��7�_k�g e�C�DO��/�Q�@�٠	_4��3�y�~�{�+�<_nK��.=�fB=����T��6B [����)����d]�$i�d]n�{k��%r��~`�����[9��o����܃�� H=Y�wA ���?t۸F�bB��bB�?;�Q���U��?5��э!�o؎N�睇g�Q������#J���2/���s���}�����lq��!/]�_���Р7�vP$"A�8�����j�"|��O��6��?{W�ʑדl�NH"�}yaX�f�M������h��nw�n�۟���F��v��m���v�^=)\a�ja'.H8!� q@BB�!$���.PU�����f�<8�Q�����Wտ��Qտ�B;m0�g��$RT����|�h���僛�v�	&�@�DX/k�)&��A�J[��MU	�Z�ABW�ˮ�}��q$����O58�xB�}���n"��4��t��E�~���23F��x\�&�Op]��r�Yn�Ѕƾ�L4o�3\��C�ʰ}̂tO����m���Į��}��^�??�������ޕLܻ�%���e;�6�71��2��>k���NP��2?''�9Fm�苃{�k���=Ài���}A���K0�NS�=i�)D�RCB�sM�(|t�L�jl�"$H��J�\���?��i�����j�����j�������D�D0j�\�.C<����D7�����my��A�'kLG�S�vmc
��b�����M������q�'�;�с���������'.;����OQ��R�i�&Ӯ��G�����'k*X6�f��oIt�!�T|8��H Шt��	��
�X�
)V���t�&sT:PՉ�"�N�]��5\6�萩���\[����w]�L���F��f�H����Fb?$~�Je�u��˜�?�_y�MϟC
w�ܟ:5M|��}�we ��P�[I���g&y
�1�e�a�h�a��=�7w����D���*#��I��D����T<Il���Q���^ɇ��%����[�����?>���	�o����?��M��ɿ�C����� ~u���_�}k�/0V�m�#�I�ɟ}��9*)�^\V�d$�K�X������^L��r�����N$�9	3$����R7���'=y�j?Y���g�~f��������|������H��#���x{��5C�A��l݆~�0�{W8��=����7�ׯ���A����[X��#��!��2� c5�(U��ts�ҋ���0Ϛ6��G����g�j���g����"�<| Xu��d����*�+0�b;�M�턴��#��
g��pVKg �NZ�O#��0�.�Bk��~,
u�朦�=fۭ��3�,����m;G�gΦD؄�Z�Ұ<�F�3�>�s6&8��lw^��-ʖ��i;����m�UL�ܼ|�n$��`��Ԡ]i3lz00���Qq���y?\
�\'a��y{lQK����X7uŢs�b�U/�$����ʳunϔ|�����>(��\�fQ5�*]+����
t�ƊP>��L��m��ĢCܴi�>[�c�:��9^��y`��)�SQ����98�b����Ɵ�R{4�����M�"[�,�4�f����<��6�T�"晴�X�k�fr����YS���Qi�f����m&�`�j4�:����XJ���5��cE�ZOH���jy�������t�%qW�%qW�%qW�%qW�%qW�%qW�%qW�%qW�%qW�%qW�%�sy�b0�o6
t4���H|��4X�v�}���ND��aΖT�\�D�zv���v��'ng5�BK�ϗ�=wq=J
�[���۹��]���p�ND*�����9�����t��S�il�DK����T�%6�g}��L�Ȓ5��I��Ή����\�;u[�3Փ	5ƶz�Z�z�Cx��E�O�cн�,��G �ir���5�x�賥MuS2��c�ڹ}��)хY<S��)��$jO�	�b2M�΍�-5�-1����,O��R��˅AT��c-��4+�n��#=��^v8K'��Z����ڋ��o};�K;���vBo���ym�m�����9��`7�����,��q��a���E�|8?���]�>���Ў�w�Qإ��l�.���}˯S(���f��k~.���#T[���G��~���
��7w�����A�w�~�����ZSVZBS&������"�SeZ�2���$�^�������9�nx>?�����s��	���r����<=�E�&jZ.�1]5�S]�e[��D`��� ��P��DZdԮ�,xf�8��$�ӬF��,�\!5Mf��}v\Urg5"���[�#93�ʕa��څ}m�v��~7Ig���5�yۚwⴙ'�\Q��q�ؠ�6q"��ʤ���n�=�����͡�4KW�� #�Ș�B��Uk�e��-�C�U�n������T�y�Z���m�F�E����>"��Z.�,����(�A�$/Qb�9SQ9I�'A������A��0Q���#f��Q�>3R�q]���F�V�����7�����~�Z�ɢ@Y��Z����&LK%.]���__^�������{��� ��� ��r�󏄯UL�������3nQf��n�4�Ic�4���+y�N�V�=u'p�F�����/7�Z�����'�S�e1�<�-Sk��Lz�T���8-w��h�Pʥ����՚c����8��K�ձ��N�����_�Gi-{6w�t��>/�����Z�m'P�@9+д}�(���ټA���\Hj���\a>S��t?���9��U�(�<��l�(\p�Ȱ^��� �GݓtU�w��b�5��+6R�"��z�=��+��u*�ʊ�t������Rt�;Z�����A1BE�b��0��e����u�N�E�H+G"�g��xt����aJrĄQ�-��֑v�v�<�ŏ:q�%!ocgB�v	�s&�*�ҙ 8�I��C!�s��J�8�՚�ݣ�x�L�*GTGzk�e&\>2sY��Y����(�����L�]'�D��z�i��1}���4"��O�G��C!<��š����x�gj磥�n��Z�������w�	1 q� nX^ߡ0�~Ik�J�5i>��q����If^�gC"�G
e4���њa�؍y;2C���ܪ-#.������t[�F��+�U�䇥�U��8��wq黡w��[0���<S�6o�Ǐ�?"�a����F�wCooDM�n���n�ZWLk�9/�B;>����|��95��X	�z�x�4t�'�#~��ЖJ�a����/������/I�{+i=�8�!H�	���AOn4��|F�ǠW&�@�d������r��x� ̾6Ri]5 Q�B{�5�~[���y��n�~�9�`���������n�в<QLS1C��.�
�MǇz]:yiҹAO�R�!^s���s��-��!<�5���y�I�.���F�~��*>���E�������M�$��z
>wr��rgb���
>6_&�����I���1+`�c0C��:'Bz�]U��Q�/�]�ݙ������6�f_]�榯��;�9$?s����\#�ѥ�yI,��VK=���k��,_�^dyM�~�.��g����-�8�R�O8 j�hOo-X���t�^��A$�(r�������N�� 䣃D�"�����3u�6 D�!FW�݃���P����A|��H.�Sӻ���$���-��S]&G
�Y�Q���Ӱ��SG^���l A=_��0�ʀ%LH8ӽ�-*�1鎟`uQ���v.�o�~�:^�@Šޙ�c\D��Y�����,2]��I1 ��Qϳ>Hd���öb��\2V�m�{����6v|f�Crm�P��k��@���`�`�Љ=�SS.|��{������:�F]m�C�n@��-�ĪSU��ew"�r����k?V6�������ݛ7o(wL4���	�v�aa?>Z�tޮ�M�G�z���ί8�$�4�Y�*�����ӑk���@�N���Өk���h]��B��]��o^b���)�2�ָ9�C܊�`�éI��$�?��eE�R^m��׸8s��@�����0>���fL0�u�aK�nɚ(:F�����6N��r�����M&�ʁ��*���
�R����(cC=��lƀ9 �Zt�Ø޽��;u�pJ@$N��|;x�e�n��x�t�J���!Byb��Q=mt������\( %��	.��Qs�;Z%Aq�Ț����*��07�x�^1�<�<
����7����6�� َ��6�g����]n9,�����з�b������K�X����	���ୃ&�ze�6K^UqU����s��%�gҤ�kW���زQ����׏��d�Mб�t���Jp��%b$:�Pi�֘�U�ɶ���ؕ@T�<r%r���0P231�=�
뚉�5�!%���Xeu��7���;Dxh���ۡP=6���0�T4�n�9�3�Lte)�����ȫ���/:�B��1��;��4��������8�1�H�lc2p��z��ҍ���W�
@�q�w�!��l��Wg�z�U�?/��w�N�k˸f�"M���G���_���J>�ǱB|�� �кNT����V��orW��xV�s4S糧Y�]��,�X��V~�ܒ��Տ�:�V�!�-�%>�*zu��K7(|5m]���8{0V�)�k�X9 �A/�HJQ �D*U@"���d���*=JN�( �R����RO�e� O+ �����d��v��+V�{Vp�{�K���.��f}���|
SPS�!7nŖ���(�cIe��L I�"�t$%��*�nd  �d<��"�dZ�IFwH��d:��S
�@��!�J�@����&�ʟbi�`�6T�:���7m���-f��F�m�n�lͿ����z��z[��\�<W��t�Tɗ�c��LV��z9��2Ͳu��x��U�Rj�o�o�X����b�5����[��d�����%�Q��g����]W�04��j^YA,�Ǉs�S�τ��V��6'ݰ�Y������Z�Z-��&���q��v���q�k����["��R7%K߾D�}�_��r���x�>[�sh���r���q�����g4_�V���,�4����)Wf��,>����a8F[��30	O�#7�:0��D���!y�R��S�KĉW�6��V�G0k����r�ϟ�9�U�	�u�<=:��]/tMw�5ɋD0��^���E�A��e�	��y"-r�_�i�npϲ�6T���>[if,������]Ys�Z�}ׯ���=hn�W�iH ��rJb�$��/`;�!�c�[;q�������W��^�t����r����'�u˗�����>^�k��F�<��S�/�e��u�؏��/7��}O�����wMϖ��l��g���ϽZ����_]{��e����l�n����=�6z�;��׏��9�ܝ�{g�/7�׻�iʿn�y�����.����/�/��ׇ���{��K����/4)P<�8��"a�
�s�o�;���������I�~����[֟�y�����[�o��Q���l���[Ɔ �����y�	p��"���u�����_���@ї��������h����	�~�g�~����H���ܝ�_��� ���#�?G���ɑ Fԙ;X���Åq䇒 Ra̋�8bB��@`�8 ��bi?�7����s����[�����|L�/���G��d�M���[��6D��m�5��(#)�ZL{���Co��O�?�J�,o�QG҅0�k�=�t��nfs��:�v�/��)5�*c������֩�ۤ�َ�5�ǐR����:^��ڏg�Y�������������0���	�����?)@�p�����g��Q ���0������_<����8A �G����R�]�%�� ��/��)�6��	0��k'��D���_8�s�-����(��_}�U�耊�V�����S���0��t�?���]�B�Qw�?��	0���a���s�?,����� �G���C �?G��R��(�R�o_��x��S���(��l^�j1�N�\���<�������{i�$���yy�0k�{?/����z?��0�U#����>��>��MS�P���,-�F��,��f\n�S�㲼���uʬ��j�y:�3�Ҫ��N�4��R�����q����7rc��ϧ�O�W�>�~6�����L�u卿Y^���+����`ul���x�a������ܝf���3#�8�N�I�工dͪij�S��KT�:��.�����f����:໭C6�6�u��	{d���)�mI,����ߵAR � ��ϭ���8�/x�?�D����'
�#�?���?��S����G��C�_:I���(@������po|���?
`�����������Ë���s�|�����χ�<��FÞOڼ��������w��?���a}��{GS�qXO�t��n�ܵP҇}0�y�uԹ�l���t�C�>W�d��󆷖��(�l�P�$�ԓ���M�Ϗ��P�k2t��oY��^�z���>�M9����CO�j�r�x駊j��J���x:��1�s����vB�N4�`$����g<���U��g�P�*�X�AVIG�ȭ����Q*����+�zR�d��"�I=z��꙽�5����`���;�����Y|L��6�� @������<���_p��8�4
(!qT�<q"�"Gr��d�b �������L�Lȇ#1�0#�ׁ������~��zjz��a����J��t����I:��Tb�ymZ1�$������(F�r�v��@�z�'����w����q���������bɨA��$M􉦹�6�>ƫ(X�.�f�e�`�Q��_���,���N}�?�������?|�?�0���	��C�W~g���l��k�����C�Έ���Κ[=\N=orN��vO��d���S�vy"��1���ڪW}�T�ܙ��z�Xr���$e��Js{N�8ϕ�hW�:�E��i��ۺL6�r7�8��^<����?��	����C������/����/����+6��`���F��%!�?xI�y���K�����ͪ��ǻ�@h4J����4-���$GO���e'%�jk�� ���w�  �ճwg ��jX��é|W��! /� ���h�v܆\.5��8���y��.U�J����r�8Z���B��X�^Shd=*	�U�m�r�;�7{;��l��&^��g��w���+\|���W�� �݊���9�*�^Q�ⓐ��Т}�VN�vlU�=ED�m�rZ�!�֠�8��b�Fj��C�m�M��V�������UB<��v�@(���z�A6��u�,F��)TJ�a��L&Ñf4�Ċm6=v�N[My�Lc�;�V��2�<�+��������XT��u��Hƻ� �G�w��>~�}���(����?����y��@��&��@�? ���������9�����������������  ���<�A@�")D~D�1����>ϳR,�"/ƌD�i>Cӑ(ŬS>�����a�!��S��	p������k���X��p1��4�M�דՃf������o�������_���u����sb��jiT=r����R�!�Fi�'�|;h��>�[���Ǔ���O�]�t]Zj����z��E2�
���8��{g�������b�P���(�����!��X�?����?D@��~����;� ��/��i�&�������ˏ���`L������ ��/��_�C�k���k-{V����q5&+}6�o��S!�ߚ�?��5&�S�}y�xO���(��i�w���~'���|��Z�k��;�qPl�:;8]��j�k06�S.�1��t�Jmٜ�{¼㎆~CnT�șL8S�o�k��FjF������i��4M����\�������D{E9���z�NPE"���,o,6����jmI����X���Ve'����a�lڰyBՓM�Ƭ�$�/��K�$h;˾�����#q��ZX�c�������)	;���Z�''G���}d��ld�A�����-h��w��n������_Z��Bp܀C�������	��꿡��������l�B
 K@��������9�_�, .�"����Ks�� ����/����o���w��I�(����.��Ң�'�>P��[��$���i�����@�����a[(������?��.
�?�C����������	0�0�(������?wg�� ^����������$ �� ��?���]�B�Q7�_��@�t���?��Â�����D����-� ����`��	���������_A��!
���[�a��p�_��0�@,��;��? �?���?��C������H���K'	����?��Â�����#V���ȁC�������������]�B�Qw��0����f�m����s�?��yv/��t���)�,2�`D��Ȑ�H��Q�b(�43ǋ�O�g�}J|)�ߗ|��ӏ���^���OA�_�����w��������j�q�?�@�*���܀m'$i�ͦ�XM��d��ג{�Cb�ڟ�����N�^һqG�TY�l�jj�Vgm��S�W�ҩ�.����	��f���pG�2�9�W���D���j����C����cS�u�x+�xe�_C��/U��8����Y
���9��
������?�����a`������8����2&w(e�n^)-k"+5G�Z���S�z���}Ȏ�Z_���_7�e�Ι[�2�*u��vlD��N�G�1IX��o$�:T�M��`۩�����*o�Sk�z]�s�i;m����:gA��Z������/"`����?��o��p������ �_���_������@,���a������xI�����/�O��z��W�����t/*�}���_%����A�]���x�W����$^��Ǭ��v��咶�I�uj�u��5�%"-��'F-���S�f���N��a'iL��|:e�fĤ�u�4~͞�N��[�Y]�ĭ��'�W���w]:�R�o�%7��U����w�T6��Z�/��IҎ�꾧h�H��m=VN��E����Z��Ho�B��mը	���H�9>�T0�D���/�{���<x#g��J���k���"�ZJMePQ2�g�H��U���R��0��h�愍����W�����F�����3^y�K���W�'���#�����W����?�8�{�����ࣟ����xa����ϒ	��8�?MR��,�?
���_O�����������ߙ�y����K�?���rt���aZ���^&�Τ$��}Ƽ9���w�T4�y��P�燥����q�ο��tN�u�Yͯ)?�s?�R~�ל�����o�=O]���<�.;���%syq-!��-�w宒���VC��u5%��9�%c�����K)?w�:����B��z���u5�G}Z�{�c$�~*uה?�%gh�9%kR?w�Uo\e�'q���i�]Qb>�ʭ�#Z�ʻf����q��������ϲ&���~�����Kv�l��{"�{����6��SR����1�I������͕�1}�-1�Y��}�eN���)�<Q�qs�
��u�;��z}��ʃ�th����i.�VN)1e�}%wCr�/��T�Cf�HO/k������/9-m���޼����M���"�'���H�XڗFLH��Y>�F$K�4?��H#�>�B2$ʏɐ������C�[��P�����_㓑\�ў�$t/�{A{�Owq��m�E��S����[��Z!�"W.j��_��~�/��7��p��?��>8�?J`n���� ���?��b�_�����?$x)��<]��������V7�(m��t�3�Qx���h�a^y,��s���$؈���f_������.�?������O���S��)�G�.�g3�̩�ʉ�Ԅ��{Wڬ(�e��+�z/^�//�������<�L*���V�o�^3o�VeVV^�ҽ"2��p�u�>g�uh�\�{���#5�GN�e��;]��y��Xo�4m�fyW3�З�� ٰjN�3WT,G��I:�|��u��3�j��u8�vlJe~Rf�H��;V����\n�)+��g����c��qZ�f�����Npld�r=�&!��Q���8֑frֶ���Xد�8js�a���8x���RHT�ۛ!�d�^���~WA�����7d��S*���AW�8V1�����t�b��4J�ժZŒ=z��U�"T��-x�V���7D�����<����{{|��?�A���m�R��9ք��i��� �z����y�Ἄ���lIU����o�����0��8��e�"�D���?�_���W��_X᱐ ��ϛ���+?d���*���?���n���?|i��O���?��
*�c��޷ZB����=����ø��W�����>�gvr]���v쫉�a��#g��Pi���J8u��Sg�M�ɗm����Jh]g��o����\!�KW����嵅��֦�}_�:/���Y��W�(t�b/:X���s)�;�E��yC��B������,��$�ZF��S����=֫:�j�.:,=��:��ޱ�2�6_�.�?�m����y���cy�ZS�ئ�V�Gʖ�8���/3S{״x��[��w���%�}c�5LN8��6�V�M}V��bb(��z4^��2d
�UL9v�ݢ-4����uX�>"�RC2�|Ñ�5u�G°f�k�1b���mU9���E�����!�'d���*�E����������S~Ȓ�!�x(D����P��	 ��?!��?a���[���5�0PH@���������!c�#�������[���3������������{�����W�w	�=d������� ��������?3B6���=BA ���?�������L����y�; ��?�'��X�)#�����?����s����/8�(��/DNȊ����C��?2�?���?<.
���;�P��	��P�? �l�W����?@�GF(�CEH~(D�����?�?d� �� �������_����c�B�?��熂�?�B�B��7�	���& �� ���w������d�<�_�X���3 �l�W�'��?@�W&(�C�^(D������!������?9!O��6Na������������&���2B!�_�	70��,)U��C/5�F�n�K�R����NҺij55�C�VØ
�����~�?<����6����l�*���I�����K��6ז��N��Z���/�c��IX��c��E�gנ��
V�N#~�b�V���$��Z'��O��uۼ=`���Q�3��8)�q�(s�q5D�z��d�txc������7�֞�{�(D4�q�«�<�V�7Or�;�����8㽛�ʻ��"�����������E��!��E����y�����00�Vx\��!���3��T�MH{q�#��Ð�i��nӸcY�y�g����[��5�k
�uw��֮���]��\
G�HB�䰩T��n�t�5��RQ9�Z�"i�ܭ���.��Xh��sy�C���(F�_��ߜ�g���Oz�#6��������� �_P��_P��?��r��#
��(�F�Up�Y�������Q�u;V�~hmՁY�8�������뿏�X�Dn!ᾶ�>Ӂ����6��h��,���}
è�p��vc����d�ռY��r�qZ���cB�\"��֯%�l+��^SĮ�Q�~E���z5l�%4WZ�۵Y��.���W)"�:�|�rñp����������2�x�q�q#����]��8}rys[P�c}��{-��W�ON4��:���s����%]l��R�Z`G׭�ٸu��y5xD��r����w���D�R��G��������Qe�^�F�N��S^x���� H�((����4����T����?����N���2����=��O�����y�?��������@������ ������S��?� w��x�m� ��ϝ��;����	�����=���?����?�Y ���������_�� w�+@�
��[���a���P���sA!�������L����sZ��~�����;
��MO��襩����l�?�X����s�GZX�|[�����#�0��~���W������Z�۽��^�7�����W�h��sg\l0{���r��⪏��9=4�5�t]L�捲�b��Ӵu��]��C_���dê9=�\Q��W&i�/�u�ײ_�Nݯ�	g��X�rر)��I�a"U��X�:��sq����<_��&r��uf�iݛI>�Ǯ;���1c�����;�4���q�#��m���_7q��<�&7Fyq�ZSy���.�7C48Ɍ�~��B�?�����W�������[���a�?7���_�(@�(D������L �_���_���o�O��ON�]�}\<�xH@������Oa��9�@�� xk"��������^O��_�?*��ٰ#v�xRu�t�Q{6����E���Ǳd]�':�ltwr��)�Q ��Ǉ��!܉��) {^S%�fU��:J3[EY��-���4�24B��ö��O�<����F	]<6*t���C}U��ք�� $-�+5 HZ�G5 ����lM���]|�������!ў�,w�$$ʶ�^�մ>/sTXs;�p�4"w(��ʽ���qHM�5s��;�f{?|��(������_� w��a�[�1��c�"����X�����F2�ZaL�Vu�VU�e���4��p�0	��
�MLe0ӤtCch�Ve�%M�����#��o�O����s���`��U��|�3gd"a��Q��d0g�AW1ע1�j������i;#���*�~�
Alu�3��f�HkJ�mߪ�j�pX*�����y�S"�(	�崁.�`�K'𩇭�����Z������k��.�w<8���C��
�����r���E �00�xH��!���3�����^�ZOR8t�!utM����V$v����؉��k�G���v���u���{��c�՜R����a�	�5��<u���
|ň�������f�'7ބ����_�b��7�_T����{����*, �#
���_�꿠�꿠��@��9�0A�QT�_N��������?꿖����;�L�(c�i4�a�MJ��^��� |O��m5 �u!��5 ��Ս@G;U�y��ˊ���i�W5}m�Ƥ���TC�hE_-�Lt���,�n���kc�L�������rg��6+�[�?�yH��8�����=߫܌��7�8%�?���^/��+0p�H���M�Z��h�)UA�5�u�m%
g,MI�:�ňry�㓫�ʣ�G�^̔��P�
����o�Q/"�rq��V��at|I癉t�loE+Ę=m�ũc��m,[�C���<��֡^�Z6}���9![k6V9���2�a;��������V�;��St��>���������	��P��Y�ҝ[�WJ���w/��/O�v�O'�M��o��$��@�����ǎ��ܛ֑�q�1=�;?ؚ��(�/���E*H�ǄNXz��G�>�6[}]z���zg]�?i�?>#o��gl���#�������ꗍ�/�t}-�K��/[����1���O��H|����3�0��S���?A��?���=����x���6���$����J��Q��m��8^TR7��qUo>!�����=R�j��6J�>��ȥz�NH]�����*��R�_��S]#y�+��������~*��O�������UrV��-�&'����1�,RH��ˆ�;�� ��c�N��޷�w��-���դm�mPj�|#�K�J�G�mK�OHr���jr��yi���	y{�s<��I(*�Ў�.9a�7J���p�F�Gr[�G���F�O���f����-���cCa���7��I^��ڻ�sr�^�#������ԟ7_�/�S�ۖ�����`�����67jD:jl<�����:�Xe�x�wII�����O��]���}O����툲��Q�\DZ��S⻬?��'���U�J/������te�/��	}zz�~    �����M� � 