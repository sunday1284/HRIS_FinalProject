<!-- 
 * == 개정이력(Modification Information) ==
 *   
 *   수정일      			수정자           수정내용
 *  ============   	============== =======================
 *  2025. 4. 5.     	KHT            최초 생성
 *
-->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.util.Date" %>

<!-- 페이지 상단 타이틀 -->
<div class="page-title dark-background" data-aos="fade" 
style="background-image: url('${pageContext.request.contextPath}/resources/BizPage/assets/img/page-title-bg.jpg');">
	<div class="container position-relative">
		<h1>채용</h1>
<!-- 		<p>Esse dolorum voluptatum ullam est sint nemo et est ipsa porro placeat quibusdam quia assumenda numquam molestias.</p> -->
		<nav class="breadcrumbs">
			<ol>
				<li><a href="${pageContext.request.contextPath }/home">Home</a></li>
				<li class="current">채용</li>
			</ol>
		</nav>
	</div>
</div>
<!-- 본문  -->
<section class="section">
	<div class="container">
		<div class="row gx-4 gy-4" data-aos="fade-up">

			<!-- 왼쪽: 상세 정보 카드 -->
			<div class="col-lg-8">
				<div class="card shadow rounded border-0 p-4 h-100">
					<div class="card-body">
						<h3 class="mb-4 text-primary fw-bold">${recruitBoardDetail.recruitTitle}</h3>
						<ul class="list-group list-group-flush mb-4" style="font-size: 1.1rem;">
							<li class="list-group-item d-flex">
								<span class="fw-bold me-3" style="min-width: 100px;">근무지</span>
								<span>${recruitBoardDetail.recruitWorkplace}</span>
							</li>
							<li class="list-group-item d-flex">
								<span class="fw-bold me-3" style="min-width: 100px;">고용형태</span>
								<span>${recruitBoardDetail.recruitHiretype}</span>
							</li>
							<li class="list-group-item d-flex">
								<span class="fw-bold me-3" style="min-width: 100px;">급여</span>
								<span>월 ${recruitBoardDetail.recruitSalary}만원</span>
							</li>
							<li class="list-group-item d-flex">
								<span class="fw-bold me-3" style="min-width: 100px;">모집부서</span>
								<span>${recruitBoardDetail.recruitPosition}</span>
							</li>
							<li class="list-group-item d-flex">
								<span class="fw-bold me-3" style="min-width: 100px;">업무내용</span>
								<span>${recruitBoardDetail.recruitWorkdetail}</span>
							</li>
							<li class="list-group-item d-flex">
								<span class="fw-bold me-3" style="min-width: 100px;">우대사항</span>
								<span>${recruitBoardDetail.recruitPq}</span>
							</li>
							<li class="list-group-item d-flex">
								<span class="fw-bold me-3" style="min-width: 100px;">모집기간</span>
								<span> 
									<fmt:formatDate value="${recruitBoardDetail.recruitStartdate}" pattern="yyyy년 MM월 dd일" />
									 ~ 
									<fmt:formatDate value="${recruitBoardDetail.recruitEnddate}" pattern="yyyy년 MM월 dd일" />
								</span>
							</li>
							<li class="list-group-item d-flex">
								<span class="fw-bold me-3" style="min-width: 100px;">문의처</span>
								<span>${recruitBoardDetail.recruitContact}</span>
							</li>
							<li class="list-group-item d-flex">
								<span class="fw-bold me-3" style="min-width: 100px;">모집인원</span>
								<span>${recruitBoardDetail.recruitHirenum}명</span>
							</li>
						</ul>

						<!-- 버튼 영역 -->
						<div class="d-flex justify-content-between align-items-center">
							<button type="button" class="btn btn-outline-secondary" onclick="history.go(-1);">
								← 뒤로가기
							</button>
						</div>
					</div>
				</div>
			</div>

			<!-- 오른쪽: D-Day + 절차 + 접수 카드 -->
			<div class="col-lg-4">
				<div class="card shadow rounded border-0 p-4 h-100">

					<!-- D-Day 뱃지 -->
					<div class="text-center mb-1">
						<strong id="dDayText" style="font-size: 2rem; font-weight: bold;">Loading...</strong>
					</div>
					<!-- 마감일을 data 속성으로 전달 -->
					<div id="recruitMeta"
						data-enddate="<fmt:formatDate value='${recruitBoardDetail.recruitEnddate}' pattern='yyyy-MM-dd' />">
					</div>

					<!-- 썸네일 -->
					<c:choose>
						<c:when test="${recruitBoardDetail.recruitPosition eq '경영지원'}">
							<c:set var="imageFileName" value="administration.png" />
						</c:when>
						<c:when test="${recruitBoardDetail.recruitPosition eq '마케팅'}">
							<c:set var="imageFileName" value="marketing.png" />
						</c:when>
						<c:when test="${recruitBoardDetail.recruitPosition eq '연구개발'}">
							<c:set var="imageFileName" value="rnd.png" />
						</c:when>
						<c:when test="${recruitBoardDetail.recruitPosition eq '생산'}">
							<c:set var="imageFileName" value="produce.png" />
						</c:when>
						<c:otherwise>
							<c:set var="imageFileName" value="dummy.jpg" />
						</c:otherwise>
					</c:choose>
					<div class="post-img mb-2 d-flex justify-content-center align-items-center"
					style="height: 200px; overflow: hidden;">
						<img src="${pageContext.request.contextPath}/resources/recruitImages/${imageFileName}"
						alt="Thumbnail" class="img-fluid rounded " style="object-fit: cover; height: 100%; width: auto;">
					</div>

					<!-- 채용 절차 -->
					<div class="mb-4">
						<div class="fw-bold fs-4 mt-3 mb-3">채용 절차</div>
						<ul class="list-unstyled text-start">
							<li class="mb-2 d-flex align-items-center fs-6 text-info fw-bold">
								<i class="bi bi-file-earmark-text me-2 text-info"></i> 서류 접수
							</li>
							<li class="mb-2 d-flex align-items-center fs-6">
								<i class="bi bi-search me-2"></i> 서류 검토
							</li>
							<li class="mb-2 d-flex align-items-center fs-6">
								<i class="bi bi-people me-2"></i> 면접 전형
							</li>
							<li class="d-flex align-items-center fs-6">
								<i class="bi bi-patch-check me-2"></i> 최종 합격 통보
							</li>
						</ul>
					</div>

					<!-- 지원 버튼 -->
					<c:set var="today" value="<%=new java.util.Date()%>" />
					<c:set var="todayFormatted">
						<fmt:formatDate value="${today}" pattern="yyyy-MM-dd" />
					</c:set>
					<c:set var="endDateFormatted">
						<fmt:formatDate value="${recruitBoardDetail.recruitEnddate}"
							pattern="yyyy-MM-dd" />
					</c:set>
					<form action="${pageContext.request.contextPath }/homepage/applicant/registerUI" method="get">
						<input type="hidden" name="recruitId" value="${recruitBoardDetail.recruitId}">
						<c:choose>
							<c:when test="${endDateFormatted < todayFormatted}">
								<button type="button" class="btn btn-secondary w-100" disabled>지원서	작성 불가</button>
							</c:when>
							<c:otherwise>
								<button type="submit" class="btn btn-primary w-100">지원서 작성</button>
							</c:otherwise>
						</c:choose>
					</form>
				</div>
			</div>

		</div>
	</div>
<%-- 	${recruitBoardDetail} --%>
</section>

<script>
	document.addEventListener("DOMContentLoaded", function() {
		const meta = document.getElementById("recruitMeta");
		const endDateStr = meta.dataset.enddate;
		const dDayText = document.getElementById("dDayText");

		if (!endDateStr || !dDayText)
			return;

		const today = new Date();
		const endDate = new Date(endDateStr + "T23:59:59");

		const diffTime = endDate - today;
		const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));

		let label = "";
		let color = "";

		if (diffDays > 0) {
			label = `D-\${diffDays}`;
			color = "#f39c12"; // 주황
		} else if (diffDays === 0) {
			label = "D-Day";
			color = "#e74c3c"; // 빨강
		} else {
			label = "모집 마감";
			color = "#95a5a6"; // 회색
		}

		dDayText.textContent = label;
		dDayText.style.color = color;
	});
</script>


 