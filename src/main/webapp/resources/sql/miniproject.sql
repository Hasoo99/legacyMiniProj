CREATE TABLE `sky`.`member` (
  `userId` VARCHAR(8) NOT NULL,
  `userPwd` VARCHAR(200) NOT NULL,
  `userName` VARCHAR(12) NULL,
  `mobile` VARCHAR(13) NULL,
  `email` VARCHAR(50) NULL,
  `registerDate` DATETIME NULL DEFAULT now(),
  `userImg` VARCHAR(50) NOT NULL DEFAULT 'avatar.png',
  `userPoint` INT NULL DEFAULT 100,
  PRIMARY KEY (`userId`),
  UNIQUE INDEX `mobile_UNIQUE` (`mobile` ASC) VISIBLE,
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE);
  
  --
  
  CREATE TABLE `sky`.`hboard` (
  `boardNo` INT NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(20) NOT NULL,
  `content` VARCHAR(2000) NULL,
  `writer` VARCHAR(8) NULL,
  `postDate` DATETIME NULL DEFAULT now(),
  `readCount` INT NULL DEFAULT 0,
  `ref` INT NULL DEFAULT 0,
  `step` INT NULL DEFAULT 0,
  `refOrder` INT NULL DEFAULT 0,
  PRIMARY KEY (`boardNo`),
  INDEX `hboard_member_fk_idx` (`writer` ASC) VISIBLE,
  CONSTRAINT `hboard_member_fk`
    FOREIGN KEY (`writer`)
    REFERENCES `sky`.`member` (`userId`)
    ON DELETE SET NULL
    ON UPDATE NO ACTION)
COMMENT = '계층형게시판';

-- 회원 가입
insert into member(userId, userPwd, userName, mobile, email)
values('tosimi', sha1(md5('1234')), '토심이', '010-2222-6666', 'tosimi@abc.com');
insert into member(userId, userPwd, userName, mobile, email)
values('tomoong', sha1(md5('1234')), '토뭉이', '010-2222-8888', 'tomoong@abc.com');

select * from member;

-- 게시판에 게시글 등록
insert into hboard(title, content, writer)
values ('안녕하세요', '반갑습니다 여러분', 'tosimi');
insert into hboard(title, content, writer)
values ('햄스터 분양하고싶어요', '골든햄스터', 'tomoong');

select * from hboard order by boardNo desc;

-- insert into hboard (title, content, writer)
values (#{title}, #{content}, #{writer});

--

CREATE TABLE `sky`.`pointdef` (
  `pointWhy` VARCHAR(20) NOT NULL,
  `pointScore` INT NULL,
  PRIMARY KEY (`pointWhy`))
COMMENT = '유저에게 적립할 포인트에 대한 정책 정의 테이블\n어떤 사유로 몇 포인트를 지급하는지에 대해 정의';

-- 

CREATE TABLE `sky`.`pointlog` (
  `pointLogNo` INT NOT NULL AUTO_INCREMENT,
  `pointWho` VARCHAR(8) NOT NULL,
  `pointWhen` DATETIME NULL DEFAULT now(),
  `pointWhy` VARCHAR(20) NOT NULL,
  `pointScore` INT NOT NULL,
  PRIMARY KEY (`pointLogNo`),
  INDEX `pointlog_member_fk_idx` (`pointWho` ASC) VISIBLE,
  CONSTRAINT `pointlog_member_fk`
    FOREIGN KEY (`pointWho`)
    REFERENCES `sky`.`member` (`userId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = '어떤 멤버에게 어떤 사유로 몇 포인트가 언제 지급되었는지 기록 테이블';

-- 글 작성시 멤버에게 포인트 로그를 저장하는 쿼리문
insert into pointlog(pointWho, pointWhy, pointScore)
values('tosimi', '글작성', (select pointScore from pointdef where pointwhy = '글작성'));
-- 멤버에게 지급된 point를 더해서 수정하는 쿼리문
update member
set userPoint = userPoint + (select pointScore from pointdef where pointwhy = '글작성')
where userId = 'tosimi';

select * from member;
select * from hboard order by ref desc, refOrder asc;
select * from pointlog;
select * from boardupfiles;

rollback;

-- hboard게시글에 업로드하는 파일정보 저장

CREATE TABLE `sky`.`boardupfiles` (
  `boardUpFileNo` INT NOT NULL AUTO_INCREMENT,
  `newFileName` VARCHAR(100) NOT NULL,
  `originFileName` VARCHAR(100) NOT NULL,
  `thumbFileName` VARCHAR(100) NULL,
  `ext` VARCHAR(20) NULL,
  `size` INT NULL,
  `boardNo` INT NULL,
  `base64Img` TEXT NULL,
  PRIMARY KEY (`boardUpFileNo`),
  INDEX `boardupfiles_boardNo-fk_idx` (`boardNo` ASC) VISIBLE,
  CONSTRAINT `boardupfiles_boardNo-fk`
    FOREIGN KEY (`boardNo`)
    REFERENCES `sky`.`hboard` (`boardNo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = '게시판에 업로드되는 파일을 기록하는 테이블';

-- 게시글에 첨부한 파일정보를 저장
select max(boardNo) from hboard;

-- 업로드된 첨부파일을 저장하는 쿼리문

-- insert into boardupfiles(newFileName,originFileName,thumbFileName,ext,size,boardNo,base64Img)
-- values(#{newFileName},#{originFileName},#{thumbFileName},#{ext},#{size},#{boardNo},#{base64Img});

-- 게시글 번호로 조회
select * from hboard where boardNo = 20;

-- 업로드 파일 조회
select * from boardupfiles where boardNo = 20;

-- 게시글 상세페이지
-- hboardNo번째 글의 hboard 모든 컬럼과, 해당글의 모든 업로드파일과, 작성자의 이름과 이메일을 가져오기위한 쿼리문
select h.boardNo, h.title, h.content, h.writer,
 h.postDate, h.readCount, h.ref, h.step, h.refOrder, f.*,
 m.userName, m.email
 from hboard h, boardupfiles f, member m
 where h.boardNo = f.boardNo
 and h.writer = m.userId
 and h.boardNo = 23;
 
 select h.boardNo, h.title, h.content, h.writer,
 h.postDate, h.readCount, h.ref, h.step, h.refOrder, f.*,
 m.userName, m.email
 from hboard h left outer join boardupfiles f
 on h.boardNo = f.boardNo
 inner join member m
 on h.writer = m.userId
 where h.boardNo = 23;
 
 -- 
 
 CREATE TABLE `sky`.`boardreadlog` (
  `boardReadLogNo` INT NOT NULL AUTO_INCREMENT,
  `readWho` VARCHAR(130) NOT NULL,
  `readWhen` DATETIME NULL DEFAULT now(),
  `boardNo` INT NULL,
  PRIMARY KEY (`boardReadLogNo`),
  INDEX `boardreadlog_boardno_fk_idx` (`boardNo` ASC) VISIBLE,
  CONSTRAINT `boardreadlog_boardno_fk`
    FOREIGN KEY (`boardNo`)
    REFERENCES `sky`.`hboard` (`boardNo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = '조회수처리를 위한 클라이언트의 ip와 게시글 읽은 시간, 게시글번호를 저장하기 위한 테이블';

-- ---- 계층형 게시판 답글 -----------------------------------
-- 1) 기존 게시글의 ref 컬럼 값을 boardNo값으로 update. 해당 작업을 수동으로 처리했음

-- 2) 앞으로 저장할 게시글에 ref컬럼 값을 boardNo 값으로 update
update hboard
set ref = ? where boardNo = ?;

-- 2-2) 부모글에 대한 다른 답글이 있는 상태에서, 부모글의 답글이 추가되는 경우,
-- (자리확보를 위해) 기존의 답글의 refOrder값을 수정해야 한다. 
-- ref = pRef and pRefOrder < refOrder
update hboard
set refOrder = refOrder + 1
where ref = ?
and refOrder > ?;

-- 2-1) 답글을 입력받아서, 답글 저장
-- ref = pRef, step = pStep + 1, refOrder = pRefOrder +1 로 등록한다
insert into hboard(title, content, writer, ref, step, refOrder)
values(?, ?, ?, ?, ?, ?)

-- 게시글 전체 목록을 가져올 때 정렬 방식 변경
-- ref 내림차순, refOrder 오름차순으로 정렬
select * from hboard order by ref desc, refOrder asc

-- 게시글 삭제
-- isDelete 컬럼추가 : 기본값 : 'N'
ALTER TABLE `sky`.`hboard` 
ADD COLUMN `isDelete` CHAR(1) NULL DEFAULT 'N' AFTER `refOrder`;

-- 게시글 내용 삭제 (isDelete='Y'로 업데이트)
update hboard
set isDelete = 'Y'
where boardNo = ?;

-- 업로드 파일 삭제 (boardupfiles테이블에서 삭제, 하드디스크에서도 삭제)
-- 1) 실제 파일을 하드디스크에서도 삭제를 해야 하므로, 삭제하기 전에
-- 	  해당 글의 업로드 파일 정보를 불러와야 한다.
select * from boardupfiles where boardNo = ?;
-- 2) 업로드파일을 boardupfiles테이블에서 삭제
delete from boardupfiles
where boardNo = ?;
-- 3) view단에서는 삭제된 글을 접근하지 못하도록 해야 한다.

-- 게시글 내용 삭제

-- 업로드 파일 삭제

-- 게시글 수정
-- 1) 순수게시글 update
update hboard
set title = ?, content = ?
where boardNo = ?;

-- 2) 업로드파일의 fileStatus = INSERT이면 insert, DELETE이면 delete
delete from boardupfiles
where boardUpFileNo = ?;

-- ---------------- 페이징 처리 ----------------------------
-- 페이징 (pagination) : 많은 데이터를 일정 단위로 끊어서 출력

-- select * from hboard order by ref desc, refOrder asc limit 보여주기시작할 index번호, 1페이지당보여줄글의갯수
select * from hboard order by ref desc, refOrder asc limit 0, 10;
select * from hboard order by ref desc, refOrder asc limit 10, 10;
select * from hboard order by ref desc, refOrder asc limit 20, 10;

-- 1) 게시판의 전체 글의 수
select count(*) from hboard; -- 351

-- 2) 전체 페이지 수
-- 만약 1페이지당 보여줄 글의 갯수 10개라고 가정한다.
-- 전체 페이지 수 : 351 / 10 = 35....1 -> 36페이지
-- ==> 전체 페이지 수 : 전체 글의 수 / 1페이지당 보여줄 글의 갯수
--                               -> 나누어 떨어지면 몫
--                               -> 나누어 떨어지지 않으면 몫 + 1

-- 3) ?번 페이지에서 보여줄 글의 시작index번호를 구하자
-- ==>  (페이지번호 - 1) * (한페이지당 보여줄 글의 갯수
-- 1페이지 : 0 = (1 - 1) * 10
-- 2페이지 : 10 = (2 - 1) * 10
-- 3페이지 : 20 = (3 - 1) * 10


-- ------------- 페이징 블럭 ------------------------
-- 1페이지 ~ 10페이지
-- 11페이지 ~ 20페이지
-- 1) 1개의 페이징 블럭에서 보여줄 페이지 수 : 10

-- 1-2) 현재 페이지가 속한 페이징 블럭의 번호
-- 7 --> 1번 블럭 --> 1번 블럭 : 7 / 10 => 나누어 떨어지지 않는 경우 : 0 + 1 번 블럭에 속함
-- 14 --> 2번 블럭 --> 2번 블럭 : 14 / 10 => 나누어 떨어지지 않는 경우 : 1 + 1 번 블럭에 속함
-- 30 --> 3번 블럭 --> 3번 블럭 : 30 / 10 => 나누어 떨어지는 경우 : 3번 블럭에 속함

-- ==> (현재페이지 번호) / (1개 페이징 블럭에서 보여줄 페이지 수)
--      -> 나누어 떨어지면 몫
--      -> 나누어 떨어지지 않으면 + 1

-- 2) 현재 ?번 페이징 블럭에서 출력시작할 페이지 번호 = ?
-- ==> (현재페이징 블럭번호 - 1) * (1개의 페이징 블럭에서 보여줄페이지 수) + 1
-- 7페이지 : 1번 블럭 -- 1 ~ 10 -> (1 - 1) * 10 + 1 --> 시작페이지 = 1번페이지 ~ 10
-- 14페이지 : 2번 블럭 -- 11 ~ 20 -> (2 - 1) * 10 + 1 --> 시작페이지 = 11번페이지 ~ 20
-- 30페이지 : 3번 블럭 -- 21 ~ 30 -> (3 - 1) * 10 + 1 --> 시작페이지 = 21번페이지 ~ 30

-- 3) 현재 번 페이징 블럭에서 출력할 마지막 페이지 번호=?
-- 2)번에서 나온 값 + (1개 페이징 블럭에서 보여줄페이지 수 -1)

-- 마지막 36페이지
-- 4번 블럭 : 31번 ~ 40번


-- 게시판 검색어 ----------------------------------
-- title로 검색
select * from hboard where title like '%테스트%';

-- writer로 검색
select * from hboard where writer like '%tomoong%';

-- content로 검색
select * from hboard where content like '%테스트%';


-- ----------------------회원가입------------------------------
-- 아이디 중복 검사 쿼리문
-- tmpUserId
select count(*) from member where userId = 'abcd'; -- 0 : 중복 안됨 



-- 회원가입 쿼리문
-- 프로필 사진을 올렸을 때
insert into member (userId, userPwd, userName, gender, mobile, email, hobby ,userImg)
values(?, sha1(md5(?)), ?, ?, ?, ?, ?, ?);
-- 프로필 사진을 올리지 않은 경우
insert into member (userId, userPwd, userName, gender, mobile, email, hobby)
values(?, sha1(md5(?)), ?, ?, ?, ?, ?);

-- 로그인
select * from member where userId = 'tosimi' and userPwd = sha1(md5('1234'));

-- 자동 로그인
ALTER TABLE `sky`.`member` 
ADD COLUMN `sesid` VARCHAR(50) NULL AFTER `userPoint`,
ADD COLUMN `allimit` DATETIME NULL AFTER `sesid`;

-- 자동로그인 정보를 저장하는 쿼리문
update member set sesid = #{sesId}, allimit = #{allimit} where userId = #{userId};

-- 쿠키에 자동로그인을 체크한 유저를 자동로그인시키기 위한 유저 정보 조회
select * from member where sesid = #{sesId} and allimit > now();

-- 댓글 게시판
ALTER TABLE `sky`.`hboard` 
ADD COLUMN `boardType` VARCHAR(10) NULL AFTER `isDelete`, COMMENT = '계층형게시판, 댓글형게시판' ;

update hboard set boardType = 'hboard' where boardNo <= 371;

ALTER TABLE `sky`.`hboard` 
CHANGE COLUMN `content` `content` LONGTEXT NULL DEFAULT NULL ;

select h.boardNo, h.title, h.content, h.writer,
		h.postDate,
		h.readCount, h.ref, h.step, h.refOrder, h.isDelete,
		m.userName,
		m.email,
		m.hobby
		from
		hboard h
		inner
		join member m
		on h.writer = m.userId
		where h.boardNo =
		374
		and
		boardType = 'cboard'
        
        -- 댓글 테이블 생성
        
        CREATE TABLE `sky`.`comment` (
  `commentNo` INT NOT NULL AUTO_INCREMENT,
  `commenter` VARCHAR(8) NULL,
  `content` VARCHAR(500) NOT NULL,
  `regDate` DATETIME NULL DEFAULT now(),
  `boardNo` INT NULL,
  PRIMARY KEY (`commentNo`),
  INDEX `boardNo_board_fk_idx` (`boardNo` ASC) VISIBLE,
  INDEX `commenter_member_fk_idx` (`commenter` ASC) VISIBLE,
  CONSTRAINT `boardNo_board_fk`
    FOREIGN KEY (`boardNo`)
    REFERENCES `sky`.`hboard` (`boardNo`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `commenter_member_fk`
    FOREIGN KEY (`commenter`)
    REFERENCES `sky`.`member` (`userId`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
COMMENT = '댓글을 저장하는 테이블';

insert into comment(commenter, content, boardNo)
values('tosimi', '테스트 댓글2', 377);

-- ?번 글의 모든 댓글 조회
select * from comment where boardNo = ? order by commentNo desc;
select * from comment where boardNo = 377 order by commentNo desc;

-- ? 글의 모든 댓글과 각 댓글의 작성자의 프로필사진을 가져오는 쿼리문
select c.*, m.userImg from member m, comment c 
where c.commenter = userId and c.boardNo = 377;

select c.*, m.userImg from comment c inner join member m
on m.userId = c.commenter
where boardNo = #{boardNo}
order by commentNo desc
limit #{startRowIndex}, #{viewPostCntPerPage}

-- ?번 글의 총 댓글 갯수
select count(*) from comment where boardNo = #{boardNo};

-- 좋아요 테이블
CREATE TABLE `sky`.`boardlike` (
  `no` INT NOT NULL,
  `who` VARCHAR(8) NULL,
  `boardNo` INT NULL,
  PRIMARY KEY (`no`),
  INDEX `boardlike_member_fk_idx` (`who` ASC) VISIBLE,
  INDEX `boardlike_boardNo_fk_idx` (`boardNo` ASC) VISIBLE,
  CONSTRAINT `boardlike_member_fk`
    FOREIGN KEY (`who`)
    REFERENCES `sky`.`member` (`userId`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `boardlike_boardNo_fk`
    FOREIGN KEY (`boardNo`)
    REFERENCES `sky`.`hboard` (`boardNo`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = '댓글형 게시글 좋아요';

ALTER TABLE `sky`.`boardlike` 
CHANGE COLUMN `no` `no` INT(11) NOT NULL AUTO_INCREMENT ;

-- hboard테이블에 likecount컬럼 추가
ALTER TABLE `sky`.`hboard` 
ADD COLUMN `likecount` INT NULL AFTER `boardType`;

-- ?번 글을 who가 좋아요 합니다.
insert into boardlike(who, boardNo) values(?,?);

-- ?번 글을 who가 좋아요 해제합니다.
delete from boardlike where who = ? and boardNo = ?;

-- ?번 글을 who가 좋아한다면, hboard에 likecount컬럼 업데이트
update hboard set likecount = likecount + 1 where boardNo = ?;

-- ?번 글을 누가 좋아하는지
select who from boardlike where boardNo = ?

-- likecount의 기본값을 0으로 설정
ALTER TABLE `sky`.`hboard` 
CHANGE COLUMN `likecount` `likecount` INT(11) NULL DEFAULT 0 ;

update hboard set likecount = likecount + 1 where boardNo = 377;