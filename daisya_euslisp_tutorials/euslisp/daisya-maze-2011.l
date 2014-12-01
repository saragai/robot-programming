;;
;; ��ư��֤�Ȥä���ϩ��æ�Ф��륵��ץ�
;;    2009/11/14 written by nakanish
;;
(load "daisya.l")
(load "maze.l")

;; (setq *m*
;;       '((1 2) (2 3) (3 4) (4 9) (9 14) (9 8)
;; 	(8 7) (7 12) (12 13) (12 11) (11 6)
;; 	(11 16) (14 15) (16 17) (17 22)
;; 	(21 22) (22 23) (23 18) (23 24)
;; 	(24 19) (19 20) (20 15) (15 10)
;; 	(10 5) (20 25)))
(setq *m*
      '((1 5) (2 3) (2 6) (3 4) (4 8) (5 6)
	(6 10) (7 11) (8 12) (9 13) (10 14)
	(11 15) (11 12) (13 14) (14 15)))

(setq *maze-column-num* 4)  ;;��ϩ�β���
(setq *maze-row-num* 4)     ;;��ϩ�νĿ�
(setq *maze-length* 470)    ;;��ϩ����������
;;
;; *m*�˥��åȤ��줿�Ͽޤκ��������ܥåȤΥ������Ȱ���(1)�ؤ�����
(defvar *maze* nil)
(warn "(maze-init)~%")
(defun maze-init
  (&optional (maze *m*) (start 1))
  (when (not (boundp '*irtviewer*))
    (setq *irtviewer* (make-irtviewer)))
  (setq *maze* (make-maze maze
                          :remove-wall-list (list '((5 4) (5 5))) ;;��������ɥ���ǥå����λ���
			  :row-num *maze-column-num*
			  :column-num *maze-row-num*
			  :maze-length *maze-length*
			  :maze-height 150.0))
  (when (not (boundp '*daisya*))
    (setq *daisya* (instance daisyaclass :init)))
  ;;�Ӥϼ���������޾���
  (send *daisya* :angle-vector #f(0 0 0 80 -20 -90 0 0))
  ;;
  (send *daisya* :locate
	(generate-coords-from-nodenum start 
				      :column-num *maze-column-num*
				      :maze-length *maze-length*) 
	:world)
  (objects (list *maze* *daisya*))
  )
;;
;;
;; ��ϩ��Ȥ��ǥ� (��ϩ�ΤȤ�õ����缫�Τ�lsp��i-search�򤴤ä�������)
(warn "(maze-demo 1 25 :extender #'depth-extender)~%")
(warn "(maze-demo 1 25 :extender #'breadth-extender)~%")
(warn "(maze-demo 1 25 :extender #'hill-climb-extender)~%")
(warn "(maze-demo 1 25 :extender #'best-first-extender)~%")
(warn "(maze-demo 1 25 :extender #'a*-extender)~%")
(defun maze-demo
  (start goal 
	 &key (extender #'depth-extender)) ;;õ����ˡ�λ���
  ;;������֤ذ�ư
  (move-daisya 
   (generate-coords-from-nodenum start :column-num (get *maze* :column-num)
				 :maze-length (get *maze* :maze-length))
   :view nil)
  (send *irtviewer* :draw-objects)
  (unix:usleep 500) ;;�ٷ�
  ;;
  (let ((path (i-search start goal (get *maze* :maze-list) :extender extender)))
    (warn "solved path is ~a~%" path)
    (dolist (p path)
      (move-daisya 
       (generate-coords-from-nodenum p :column-num (get *maze* :column-num)
				       :maze-length (get *maze* :maze-length)))
      ))
  )
;;
;;
;; ��֤��ɸ�ذ�ư������ʥ��˥᡼�����)
;;   ��ž����ư��ɬ�פʾ��Ϥ��Τ褦��
;; �ǽ�ϰ�ư��angle-vector��ȤäƤ����Τ�����ɡ���ư����������
;;   base-x,y,z�����ˤ����Ƥ��äƤ��ޤ�orz
(defun draw-viewers nil (send *irtviewer* :draw-objects))
(defun move-daisya
  (c ;;c�Ϻ�ɸ #f(0 0 0)�ߤ����ʤ��
   &key   
   (view t)               ;;���褹��
   (ticktime 50)          ;;������ε٤߻���[msec]
   (interpolation-num 10) ;;�䴰��
   )
  (let* ((current-pos (send *daisya* :worldpos))
	 ;;���ߤΥ��ܥåȤθ���
	 (current-angle (rad2deg 
			 (atan (aref (matrix-column (send *daisya* :worldrot) 0) 1)
			       (aref (matrix-column (send *daisya* :worldrot) 0) 0))))
	 (diff-vector (v- c current-pos))
	 ;;��ɸ�Υ��ܥåȤθ���
	 (goal-angle (rad2deg (atan (aref diff-vector 1) (aref diff-vector 0))))
	 diff-angle
	 )
    (cond
     (view ;;current-vector -> goal-vector�ޤ��䴰����ɽ��
      (setq diff-vector (scale (/ 1.0 interpolation-num) diff-vector))
      (setq diff-angle (/ (- goal-angle current-angle) interpolation-num))
      (dotimes (i interpolation-num)
	(send *daisya* :translate diff-vector :world)   ;;�¹԰�ư
	(send *daisya* :rotate (deg2rad diff-angle) :z) ;;��ž
        (send *daisya* :simulate (send *maze* :bodies))
        (draw-viewers) ;;����
	(unix:usleep (* 1000 ticktime)))
      )
     (t
      ;;���֤򤢤碌��
      (send *daisya* :translate diff-vector :world) ;;�¹԰�ư
      ;;��ž�򤢤碌��
      (send *daisya* :rotate (deg2rad (- goal-angle current-angle)) :z) ;;��ž
      ))
    ))
  



  
  
	 
    