<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<style>
thead th {
    text-align: center !important;
}
.modal-title {
	color: white !important;
    flex-grow: 1; /* 제목이 가운데 정렬될 수 있도록 설정 */
    text-align: center;
}
.modal-header .btn-close {
    filter: invert(1); /* 아이콘 색 반전 (검정 → 흰색) */
    opacity: 1; /* 기본 부트스트랩 스타일보다 더 뚜렷하게 표시 */
}
.modal-body strong {
    display: inline-block;
    width: 120px; /* 라벨 너비 통일 */
    font-weight: bold;
    color: #333;
}
.applicant-button {
    pointer-events: auto !important;
}
.modal.fade .modal-dialog {
    transition: transform 0.3s ease-out;
    transform: translateY(-10px);
}

.modal.show .modal-dialog {
    transform: translateY(0);
}

/* th 정렬 숨김 */
th a.dataTable-sorter::after {
	display: none !important; 
}
th a.dataTable-sorter::before {
	display: none !important; 
}
th a.dataTable-sorter {
	pointer-events: none; 
}

/* ===.dataTable css 테스트 === */
.dataTable-top {
 	display: none; 
}
.dataTable-bottom {
 	display: none; 
}
.dataTable-dropdown {
 	display: none !important; 
}
#table1.table.table-striped.text-center tbody tr td,
#table1.table.table-striped.text-center tbody tr td * {
  font-size: 15px !important;
}
</style>

<!-- chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>

<!-- 뒤로가기, Breadcrumb 통일 -->
<div class="page-container container-fluid">
  <div class="d-flex justify-content-between align-items-center mb-2">
    <!-- 좌측: 버튼 그룹 -->
    <div>
      <button type="button" class="btn btn-outline-secondary" onclick="history.back();">
        <i class="fas fa-arrow-left"></i>
      </button>
    </div>
    <!-- 우측: Breadcrumb -->
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb mb-0">
        <li class="breadcrumb-item fw-bold text-primary"><a href="${pageContext.request.contextPath }/account/login/home"> 📌 Main</a></li>
        <li class="breadcrumb-item active" aria-current="page">채용공고 관리</li>
        <li class="breadcrumb-item">
          <a href="${pageContext.request.contextPath }/recruit/interview/list">면접자 관리</a>
        </li>
      </ol>
    </nav>
  </div>
</div>

<div class="page-heading">
	<section class="section">
		<div class="card">
			<div class="card-header">
				<h3>채용공고 관리</h3><hr>
<!-- 				<p class="text-subtitle text-muted"></p> -->
			</div>
			<div class="card-body">
				<div style="font-weight: bold; color: black;" >⚠️미평가지원서 : 1차평가 필요 </div>
				<div style="font-weight: bold; color: black;" >⚠️각 지원서목록에서 1차평가 진행 </div>
				<br>
				<!-- chart -->
				<div style="display: flex; justify-content: center; align-items: center; width: 100%;">
					<div style="width: 60%; height: 40%;">
						<canvas id="applicantChart"></canvas>
					</div>
					<div style="width: 40%; max-width: 300px; margin-left: 40px;">
						<canvas id="statusChart" width="300" height="300"></canvas>
					</div>
				</div>
				<br>
				<hr>
				<!-- 연도 반기 선택 조회 버튼 -->
				<div class="d-flex align-items-center gap-2 ">
					<fmt:setLocale value="ko_KR"/>
					<fmt:formatDate value="<%= new java.util.Date() %>" pattern="yyyy" var="currentYear"/>
					<fmt:formatDate value="<%= new java.util.Date() %>" pattern="MM" var="currentMonth"/>
				    <select id="yearSelect" class="form-select w-auto">
				        <c:forEach var="i" begin="2022" end="${currentYear }">
				            <option value="${i}" ${i == currentYear ? 'selected' : ''}>${i}년</option>
				        </c:forEach>
				    </select>
				    <select id="halfSelect" class="form-select w-auto">
				        <option value="상" ${currentMonth <= 6 ? 'selected' : ''}>상반기</option>
        				<option value="하" ${currentMonth > 6 ? 'selected' : ''}>하반기</option>
				    </select>
				    <button class="btn btn-outline-primary" id="searchButton">조회</button>
				</div><br>
				<!-- 메인테이블 -->
				<table class="table table-striped text-center" id="table1">
					<thead>
						<tr>
							<th>제목</th>
							<th>모집부서</th><!-- td:nth-child(2) -->
							<th>고용형태</th>
							<th>모집기간</th>
							<th>누적지원서</th>
							<th>미평가지원서</th><!-- td:nth-child(6) -->
							<th>지원서목록</th>
						</tr>
					</thead>
					<tbody>
						<c:choose>
							<c:when test="${not empty recruitBoardList }">
								<c:forEach items="${recruitBoardList }" var="recruitBoard">
									<tr class="recruit-row"
									data-enddate="<fmt:formatDate value='${recruitBoard.recruitEnddate}' pattern='yyyy-MM-dd' />"
									data-startdate="<fmt:formatDate value='${recruitBoard.recruitStartdate}' pattern='yyyy-MM-dd' />">
										<td class="text-start">
											<%-- rId:${recruitBoard.recruitId} --%>
											<!-- 상세조회 모달창 띄우는 제목 -->
											<a class="recruit-detail-link" data-recruit-id="${recruitBoard.recruitId}" style="cursor: pointer;">
												${recruitBoard.recruitTitle}
											</a>
											<%-- 기존 이동되던 페이지
											<a href="${pageContext.request.contextPath }/recruit/board/detail?recruitId=${recruitBoard.recruitId}">
										        (page)
										    </a>
			      							--%>
										</td>
										<td>
											${recruitBoard.recruitPosition }
										</td>
										<td>
											${recruitBoard.recruitHiretype }
										</td>
										<td>
											<span class="recruit-end-date" data-status="open">
				                                <fmt:formatDate value="${recruitBoard.recruitStartdate}" pattern="yyyy-MM-dd" />
				                                ~
				                                <fmt:formatDate value="${recruitBoard.recruitEnddate}" pattern="yyyy-MM-dd" />
				                            </span>
										</td>
										<td>
											${recruitBoard.applicantCount }
										</td>
										<td>
											${recruitBoard.waitingCount }
										</td>
										<td>
											<span class="applicant-count" hidden>${recruitBoard.applicantCount}</span>
											<a href="${pageContext.request.contextPath }/recruit/applicant/list?recruitId=${recruitBoard.recruitId}"
											class="btn btn-outline-primary btn-sm applicant-button" data-recruit-id="${recruitBoard.recruitId}"
											style="width: 60px; text-align: center;">
										        이동
										    </a>
										</td>
									</tr>
								</c:forEach>
							</c:when>
							<c:otherwise>
								<tr>
									<td colspan="7">공고가 존재하지 않습니다.</td>
								</tr>
							</c:otherwise>
						</c:choose>
					</tbody>
				</table>
				<br>
				<!-- 등록 모달 버튼 -->
				<div class="d-flex justify-content-end mt-3">
				    <button class="btn btn-primary" id="registerModal">
				        공고 등록
				    </button>
				</div>
			</div>
		</div>
<%-- ${recruitBoardList } --%>
	</section>
</div>

<!-- 채용공고 등록 모달 -->
<div class="modal fade" id="recruitModal" tabindex="-1"	aria-labelledby="registerModalLabel" >
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header bg-primary">
				<h5 class="modal-title" id="registerModalLabel">채용공고 작성</h5>
				<button type="button" class="btn-close" data-bs-dismiss="modal"	aria-label="Close"></button>
			</div>
			<div class="modal-body">
				<form id="insert-form">
					<div class="mb-3">
						<label for="recruitTitle" class="form-label"><strong>제목</strong></label>
						<input type="text" class="form-control" id="recruitTitle"
							name="recruitTitle" placeholder="YYYY 반기 팀명 채용">
					</div>
					<div class="mb-3 d-flex align-items-center">
						<div class="me-5">
							<label for="recruitWorkplace" class="form-label"><strong>근무지</strong></label>
							<input type="text" class="form-control" id="recruitWorkplace"
								name="recruitWorkplace" style="width:150px;">
						</div>
						<div style="margin-left: 45px;">
							<label for="recruitHiretype" class="form-label"><strong>고용형태</strong></label>
							<select class="form-control" id="recruitHiretype"
								name="recruitHiretype">
								<option value="" disabled selected>선택하세요</option>
								<option value="정규직">정규직</option>
								<option value="계약직">계약직</option>
							</select>
						</div>
					</div>
					<div class="mb-3 d-flex align-items-center">
						<div class="mb-3 me-5 me-lg-7">
						    <label for="recruitSalary" class="form-label"><strong>급여</strong></label>
						    <div class="d-flex align-items-center">
						        <span class="me-2">월</span>
						        <input type="text" class="form-control" id="recruitSalary" name="recruitSalary" style="width: 80px;">
						        <span class="ms-2">만원</span>
						    </div>
						</div>
						<div style="margin-left: 50px;">
							<label for="recruitPosition" class="form-label"><strong>모집부서</strong></label>
							<select class="form-control" id="recruitPosition"
								name="recruitPosition">
								<option value="" disabled selected>선택하세요</option>
								<option value="경영지원">경영지원</option>
								<option value="마케팅">마케팅</option>
								<option value="연구개발">연구개발</option>
								<option value="생산">생산</option>
							</select>
						</div>
					</div>
					<div class="mb-3">
						<label for="recruitWorkdetail" class="form-label"><strong>업무내용</strong></label>
						<input type="text" class="form-control" id="recruitWorkdetail"
							name="recruitWorkdetail">
					</div>
					<div class="mb-3">
						<label for="recruitPq" class="form-label"><strong>우대사항</strong></label>
						<input type="text" class="form-control" id="recruitPq"
							name="recruitPq">
					</div>
					<div class="mb-3 d-flex align-items-center">
					    <div class="me-5">
					        <label for="recruitStartdate" class="form-label"><strong>시작일</strong></label>
					        <input type="date" class="form-control" id="recruitStartdate" name="recruitStartdate">
					    </div>
					    <div style="margin-left: 35px;">
					        <label for="recruitEnddate" class="form-label"><strong>마감일</strong></label>
					        <input type="date" class="form-control" id="recruitEnddate" name="recruitEnddate">
					    </div>
					</div>
					<div class="mb-3 d-flex align-items-center">
						<div class="me-5">
							<label for="recruitContact" class="form-label"><strong>문의처</strong></label>
							<input type="text" class="form-control" id="recruitContact"
								name="recruitContact" style="width:150px;">
						</div>
						<div style="margin-left: 45px;">
							<label for="recruitHirenum" class="form-label"><strong>모집인원</strong></label>
						    <div class="d-flex align-items-center">
						        <input type="text" class="form-control" id="recruitHirenum" name="recruitHirenum" style="width: 80px;">
						        <span class="ms-2">명</span>
						    </div>
						</div>
					</div><br>
					<div class="d-flex justify-content-center">
						<button type="button" class="btn btn-success ms-2" id="fillExample">예시</button>
						<button type="button" class="btn btn-primary ms-2" id="submitRecruit">등록</button>
						<button type="button" class="btn btn-secondary ms-2" data-bs-dismiss="modal" id="closeRecruitModal">
							닫기
						</button>
					</div>
				</form>
			</div>
		</div>
	</div>
</div>
<!-- 채용공고 상세조회 모달 -->
<div class="modal fade" id="recruitDetailModal" tabindex="-1" aria-labelledby="detailModalLabel" >
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary">
                <h5 class="modal-title" id="detailModalLabel">채용공고 상세 정보</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <table class="table">
                    <tr>
                    	<th><strong>제목</strong></th>
                    	<td id="modalRecruitTitle"></td>
                    </tr>
                    <tr>
                    	<th><strong>근무지</strong></th>
                    	<td id="modalRecruitWorkplace"></td>
                    </tr>
                    <tr>
                    	<th><strong>고용형태</strong></th>
                    	<td id="modalRecruitHiretype"></td>
                    </tr>
                    <tr>
                    	<th><strong>급여</strong></th>
                    	<td id="modalRecruitSalary"></td>
                    </tr>
                    <tr>
                    	<th><strong>모집부서</strong></th>
                    	<td id="modalRecruitPosition"></td>
                    </tr>
                    <tr>
                    	<th><strong>업무내용</strong></th>
                    	<td id="modalRecruitWorkdetail"></td>
                    </tr>
                    <tr>
                    	<th><strong>우대사항</strong></th>
                    	<td id="modalRecruitPq"></td>
                    </tr>
                    <tr>
                    	<th><strong>시작일</strong></th>
                    	<td id="modalRecruitStartdate"></td>
                    </tr>
                    <tr>
                    	<th><strong>마감일</strong></th>
                    	<td id="modalRecruitEnddate"></td>
                    </tr>
                    <tr>
                    	<th><strong>문의처</strong></th>
                    	<td id="modalRecruitContact"></td>
                    </tr>
                    <tr>
                    	<th><strong>모집인원</strong></th>
                    	<td id="modalRecruitHirenum"></td>
                    </tr>
                </table>
				<div class="d-flex justify-content-center">
					<button type="button" class="btn btn-primary ms-2" id="updateRecruitBtn">수정</button>
					<button type="button" class="btn btn-secondary ms-2" data-bs-dismiss="modal" id="closeRecruitModal">
						닫기
					</button>
				</div>
            </div>
        </div>
    </div>
</div>


<script>

document.addEventListener('DOMContentLoaded', function() {
//table1 셀렉트박스 설정하기 ========================================
	    // 테이블 요소 가져오기
		const tableEl = document.querySelector('#table1');
	    // dataTable 초기화
	    const dataTable = new simpleDatatables.DataTable(tableEl);

	    // 페이지 당 perPage 값을 강제로 15로 설정
	    dataTable.options.perPage = 15;
	    dataTable.page(1); // 페이지 다시 로딩

	    // 테이블 내부에 있는 드롭다운 값도 15로 변경
	    const selector = dataTable.wrapper.querySelector('.dataTable-selector');
	    if (selector) {
	        selector.value = '15';
	        selector.dispatchEvent(new Event('change'));
	    }
	    // 셀렉트 스타일 유지
	    function adaptPageDropdown() {
	        const selector = dataTable.wrapper.querySelector(".dataTable-selector");
	        selector.parentNode.parentNode.insertBefore(selector, selector.parentNode);
	        selector.classList.add("form-select");
	    }
	    // 페이지네이션 스타일 유지
	    function adaptPagination() {
	        const paginations = dataTable.wrapper.querySelectorAll("ul.dataTable-pagination-list");
	        paginations.forEach(p => p.classList.add("pagination", "pagination-primary"));

	        const paginationLis = dataTable.wrapper.querySelectorAll("ul.dataTable-pagination-list li");
	        paginationLis.forEach(li => li.classList.add("page-item"));

	        const paginationLinks = dataTable.wrapper.querySelectorAll("ul.dataTable-pagination-list li a");
	        paginationLinks.forEach(link => link.classList.add("page-link"));
	    }
	    // 페이지네이션 새로 적용
	    const refreshPagination = () => {
	        adaptPagination();
	    }
	    // 이벤트에 따라 스타일 적용
	    dataTable.on("datatable.init", () => { 					// 테이블 초기화 시 드롭다운&페이지네이션 스타일 설정
	        adaptPageDropdown();
	        refreshPagination();
	    });
	    dataTable.on("datatable.update", refreshPagination); 	// 데이터 갱신될 때 페이지네이션 스타일 재적용
	    dataTable.on("datatable.sort", refreshPagination); 		// 데이터 정렬될 때    ~
	    dataTable.on("datatable.page", adaptPagination); 		// 페이지 이동 시 페이지네이션 새로 적용

	
//////////////////////////////////////////////////////////////////////////////////////////////	
	
// 모집기간(시작~마감)을 "모집마감"으로 처리

	// 현재 날짜 가져오기 (yyyy-mm-dd 형식) 00:00:00 시간으로 설정
	const today = new Date();
	today.setHours(0, 0, 0, 0);

	// 모든 모집기간 행 순회
	document.querySelectorAll('.recruit-row').forEach(row => {
	  const endDateString = row.getAttribute('data-enddate'); // endDate를 data-속성에서 가져오기
	  const endDate = new Date(endDateString); // 모집 마감일을 Date 객체로 변환
	  endDate.setHours(23, 59, 59, 999);  // 마감일 시간을 23:59:59로 설정

	  // 마감일이 오늘 이전인 경우 "모집마감"으로 표시
	  const recruitEndDateElement = row.querySelector('.recruit-end-date');
	  if (endDate < today) {
		  recruitEndDateElement.textContent = "모집마감";
		  recruitEndDateElement.dataset.status = "close"; // 상태를 close로 변경
	  } else {
		  recruitEndDateElement.dataset.status = "open"; //  상태를 open으로 변경

	  }


	});

//////////////////////////////////////////////////////////////////////////////////////////////

// 연도 & 반기 선택 조회
	//기간 필터링 함수 정의
	function filterRecruit() {
       const selectedYear = document.getElementById('yearSelect').value;
       const selectedHalf = document.getElementById('halfSelect').value; // "상" 또는 "하"

       document.querySelectorAll('.recruit-row').forEach(row => {
           const startDateStr = row.getAttribute('data-startdate');
           const startDate = new Date(startDateStr);
           const rowYear = startDate.getFullYear();
           const rowMonth = startDate.getMonth() + 1; // 월은 0부터 시작하므로 +1

           // 연도가 일치하고, 반기 조건에 맞으면 보이기
           if (rowYear == selectedYear) {
               if (selectedHalf === "상" && rowMonth >= 1 && rowMonth <= 6) {
                   row.style.display = '';
               } else if (selectedHalf === "하" && rowMonth >= 7 && rowMonth <= 12) {
                   row.style.display = '';
               } else {
                   row.style.display = 'none';
               }
           } else {
               row.style.display = 'none';
           }
       });

       //조건에 해당하는 차트로 갱신
       updateChart();


   }

	//검색 버튼 클릭 시 filterRecruit 함수 실행
	document.getElementById('searchButton').addEventListener('click', filterRecruit);
	//페이지 로드 시 초기 필터 적용(현재 연도&반기)
	filterRecruit();


//////////////////////////////////////////////////////////////////////////////////////////////


//차트
	// 필터링된 공고만 이용하여 차트를 업데이트하는 함수
	function updateChart() {
	    // 보이는(recruit-row 스타일이 보이는) 공고만 선택
	    const visibleRows = Array.from(document.querySelectorAll('.recruit-row'))
	                              .filter(row => row.style.display !== 'none');

	//공고 별 지원자 수 bar chart==================================================	
	    
		//차트 데이터 생성
	    let recruitData = [];
	    
	    visibleRows.forEach(row => {
	        const originalTitle = row.querySelector('.recruit-detail-link').textContent.trim();
	        const endDateStr = row.getAttribute('data-enddate'); 

	        // yyyy 반기 패턴 제거
	        let cleanedTitle = originalTitle.replace(/^\d{4}년?\s[상|하]반기\s/, "").trim();
	        // 팀명 추출
	        let teamMatch = cleanedTitle.match(/\S*팀/);
	        let shortTitle = teamMatch ? teamMatch[0] : cleanedTitle;
	        // 모집부서 정보 가져오기
	        const recruitDepartment = row.querySelector('td:nth-child(2)').textContent.trim();

	        const applicantCount = row.querySelector('.applicant-count')
	            ? parseInt(row.querySelector('.applicant-count').textContent.trim(), 10)
	            : 0;

	        // d-day 계산
	        const today = new Date();
	        const endDate = new Date(endDateStr);
	        const dDay = Math.ceil((endDate - today) / (1000 * 60 * 60 * 24));
	        
	        recruitData.push({ originalTitle, shortTitle, department: recruitDepartment, applicantCount, dDay });
	    });

	    // 제목 기준 오름차순 정렬
	    // 모집부서명 → 팀명 순으로 정렬
		recruitData.sort((a, b) => {
		    // 모집부서 기준으로 정렬
		    let departmentCompare = a.department.localeCompare(b.department, 'ko-KR');
		    // 모집부서가 같다면 팀명(shortTitle) 기준으로 정렬
		    if (departmentCompare === 0) {
		        return a.shortTitle.localeCompare(b.shortTitle, 'ko-KR');
		    }
		    return departmentCompare;
		});

	    // 차트 데이터 구성
	    // 라벨은 "모집부서 - 팀명" 으로 표시
    	const labels = recruitData.map(function(item) {
		    let dDayText = "";
		    if (item.dDay > 0) {
		        dDayText = "D-" + item.dDay;
		    } else if (item.dDay === 0) {
		        dDayText = "D-DAY";
		    } else {
		        dDayText = "마감";
		    }
		    return item.shortTitle 
// 		    		+ "(" + item.department + ")\n" 
					+ "\n"
		    		+ dDayText;
		});

	    const applicantCounts = recruitData.map(item => item.applicantCount);
	    const originalTitles = recruitData.map(item => item.originalTitle);

	 	// 선택된 연도와 반기 값
	    var selectedYear = document.getElementById("yearSelect").value;
	    var selectedHalf = document.getElementById("halfSelect").value; // "상" 또는 "하"
	    var halfText = selectedHalf === "상" ? "상반기" : "하반기";
	    var datasetLabel = selectedYear + " " + halfText + " 지원 현황";

	 	// 모집부서 별 고정 색상 매핑
	    const departmentColorMap = {
	        "경영지원": "#FF6384", 	// 빨강
	        "생산": "#36A2EB",      	// 파랑
	        "연구개발": "#FFCE56",  	// 노랑
	        "마케팅": "#4BC0C0"     	// 청록
	    };
	 	
	 	// 실제 등장한 부서 순서대로 정렬된 목록
	    const uniqueDepartmentsInOrder = [];
	    recruitData.forEach(item => {
	        if (!uniqueDepartmentsInOrder.includes(item.department)) {
	            uniqueDepartmentsInOrder.push(item.department);
	        }
	    });

	 	// 각 데이터 항목의 모집부서에 따라 색상 지정
	    const backgroundColors = recruitData.map(item => {
	        return departmentColorMap[item.department] || "#808080"; // 매핑에 없으면 회색
	    });

	    // 기존 차트 인스턴스가 있다면 제거 후 재생성
	    if (window.applicantChartInstance) {
	        window.applicantChartInstance.destroy();
	    }
	    const ctx = document.getElementById('applicantChart').getContext('2d');
	    
	    window.applicantChartInstance = new Chart(ctx, {
	        type: 'bar',
	        data: {
	            labels: labels,
	            datasets: [{
	                label: datasetLabel,
	                data: applicantCounts,
	                backgroundColor: backgroundColors,
	                borderColor: backgroundColors,
	                borderWidth: 1
	            }]
	        },
	        options: {
	            responsive: true,
	            plugins: {
	            	title: {
	                    display: true,
	                    text: datasetLabel, // 상단 제목으로 사용
	                    color: 'black',
	                    font: { size: 18, weight: 'bold' },
	                    padding: {
	                        top: 10,
	                        bottom: 20
	                    }
	                },
	                legend: {
	                    position: 'top',
	                    labels: {
	                        font: {
	                            size: 14
	                        },
	                        generateLabels: function(chart) {
                                return uniqueDepartmentsInOrder.map(department => ({
                                    text: department + "본부",
                                    fillStyle: departmentColorMap[department] || "#808080",
                                    strokeStyle: departmentColorMap[department] || "#808080",
                                    lineWidth: 1,
                                    hidden: false,
                                    index: 0
	                            
	                            }));
	                        }
	                    }
	                },
	                tooltip: {
	                    callbacks: {
	                        title: function(tooltipItems) {
	                            let index = tooltipItems[0].dataIndex;
	                            return originalTitles[index];
	                        },
	                        label: function(tooltipItem) {
	                            return tooltipItem.raw + '명';
	                        }
	                    }
	                },
	                datalabels: {
	                    anchor: 'end',
	                    align: 'end',
	                    color: '#000',
	                    formatter: function(value) {
	                        return value + '명';
	                    }
	                }
	            },
	            scales: {
	                x: {
	                    ticks: {
	                        autoSkip: true,
	                        callback: function(value, index) {
	                            return this.getLabelForValue(value).split('\n');
	                        }
	                    },
	                    grid: { display: false }
	                },
	                y: {
	                    beginAtZero: true,
	                    max: 10,
	                    ticks: {
	                        stepSize: 2,
	                        callback: function(value) { return value; }
	                    },
	                    grid: { display: false }
	                }
	            }
	        },
	        plugins: [ChartDataLabels]
	    });
	    
	// 도넛 차트 ===========================================
	 	// 모집부서별 지원서 수 집계
	    const departmentCounts = {};
	    recruitData.forEach(item => {
	        if (!departmentCounts[item.department]) {
	            departmentCounts[item.department] = 0;
	        }
	        departmentCounts[item.department] += item.applicantCount;
	    });

	    // 정렬된 부서 목록 (등장 순서 기준)
	    const sortedDepartments = Object.keys(departmentCounts);
	    // 각 부서에 대응하는 지원자 수
	    const departmentData = sortedDepartments.map(dept => departmentCounts[dept]);
	    // 지원자 수 총합
	    const totalApplicants = departmentData.reduce((sum, val) => sum + val, 0);

	    // 기존 차트 인스턴스 제거
	    if (window.statusChartInstance) {
	        window.statusChartInstance.destroy();
	    }

		// 파이(도넛) 차트 생성
	    const statusCtx = document.getElementById('statusChart').getContext('2d');
	    window.statusChartInstance = new Chart(statusCtx, {
	        type: 'doughnut',
	        data: {
	            labels: sortedDepartments,
	            datasets: [{
	                data: departmentData,
	                backgroundColor: sortedDepartments.map(dept => departmentColorMap[dept] || '#808080')
	            }]
	        },
	        options: {
	            responsive: true,
	            cutout: '60%', // 도넛 크기 조절
	            plugins: {
	                legend: {
	                    position: 'top',
	                    labels: { font: { size: 14 } }
	                },
	                tooltip: {
	                    callbacks: {
	                        label: function(context) {
	                            const value = context.raw;
	                            const label = context.label;
	                        	// 전체 합계 
	                            const total = context.dataset.data.reduce((sum, val) => sum + val, 0);
	                         	// 퍼센트 계산 (소수점 한 자리)
	                            const percentage = ((value / total) * 100).toFixed(1);
	                            return `\${percentage}%`;
	                        }
	                    }
	                },
	                title: {
	                    display: true,
	                    text: '모집부서별 지원자',
	                    padding: { bottom: 10 },
	                    color: 'black',
	                    font: { size: 18, weight: 'bold' }
	                },
	                datalabels: {
	                    color: '#fff',
	                    font: { weight: 'bold', size: 14 },
	                    textStrokeColor: '#000',   // 테두리 색
	                    textStrokeWidth: 2,        // 테두리 두께
	                    formatter: function(value, context) {
	                        const label = context.chart.data.labels[context.dataIndex];
	                        return label + ' ' + value + '명';
	                    }
	                }
	            }
	        },
	        plugins: [
	            ChartDataLabels,
	            {
	                id: 'centerText',
	                beforeDraw(chart) {
	                    const { width } = chart;
	                    const { height } = chart;
	                    const ctx = chart.ctx;
	                    ctx.save();
	                    
	                    const fontSize = Math.min(height / 10, 20);
	                    ctx.font = `\${fontSize}px sans-serif`;
	                    ctx.fillStyle = '#333';
	                    ctx.textAlign = 'center';   // 가운데 정렬 (가로)
	                    ctx.textBaseline = 'middle'; // 가운데 정렬 (세로)

	                    const text = `총 \${totalApplicants}명`;
	                    const textX = width / 2;
	                    const textY = height / 2 + 35;

	                    ctx.fillText(text, textX, textY);
	                    ctx.restore();
	                }
	            }
	        ]
	    });
	    
	    /*     
	    
		//평가&미평가 지원서 pie chart ==================================================	    	    
		 	// 평가 진행률 차트 (Pie) - 누적 지원서 기준
		    let totalApplicants = 0;
		    let totalWaiting = 0;

		    // 보이는 공고들의 전체 수치 누적합 계산
		    visibleRows.forEach(row => {
		        const applicantCount = row.querySelector('.applicant-count')
		            ? parseInt(row.querySelector('.applicant-count').textContent.trim(), 10)
		            : 0;
		        const waitingCount = row.querySelector('td:nth-child(6)').textContent.trim(); // 미평가지원서

		        totalApplicants += applicantCount;
		        totalWaiting += parseInt(waitingCount || 0, 10);
		    });

		    const evaluatedCount = totalApplicants - totalWaiting;

		    // 기존 파이 차트 인스턴스 제거
		    if (window.statusChartInstance) {
		        window.statusChartInstance.destroy();
		    }

		    const statusCtx = document.getElementById('statusChart').getContext('2d');
		    window.statusChartInstance = new Chart(statusCtx, {
		        type: 'pie',
		        data: {
		            labels: ['미평가', '평가 완료'],
		            datasets: [{
		                data: [totalWaiting, evaluatedCount],
		                backgroundColor: ['#28A745', '#808080'],
		            }]
		        },
		        options: {
		            responsive: true,
		            plugins: {
		                legend: {
		                    position: 'top',
		                    padding: {
		                        bottom: 20
		                    }
		                },
		                tooltip: {
		                    callbacks: {
		                        label: function(tooltipItem) {
		                            const value = tooltipItem.raw;
		                            const label = tooltipItem.label;
		                            return ` \${value}건`;
		                        }
		                    }
		                },
		                title: {
		                    display: true,
		                    text: '1차평가 진행 현황',
		                    padding: {
		                        bottom: 10
		                    },
		                    color: 'black',
		                    font: {
		                        size: 18,        
		                        weight: 'bold'   
		                    }
		                },
		                datalabels: {
		                    color: '#fff', 
		                    font: {
		                        weight: 'bold',
		                        size: 14
		                    },
		                    formatter: function(value, context) {
		                    	const label = context.chart.data.labels[context.dataIndex];
//	 	                    	return value + '건';
		                    	return label + ' ' + value + '건'
		                    }
		                }
		            }
		        },
		        plugins: [ChartDataLabels]
		    });
		    
		     */
		     
	 }


//////////////////////////////////////////////////////////////////////////////////////////////

//등록 모달 & 비동기


	// yyyy-MM-dd 형식으로 날짜 포맷팅하는 함수
    function formatDate(date) {
        const yyyy = date.getFullYear();
        const mm = String(date.getMonth() + 1).padStart(2, '0'); // 1월 = 0
        const dd = String(date.getDate()).padStart(2, '0');
        return `\${yyyy}-\${mm}-\${dd}`;
    }
    
    // 예시 데이터 넣기 ***************************************
    document.getElementById("fillExample").addEventListener("click", function () {
        document.getElementById("recruitTitle").value = `2025 상반기 프론트엔드개발팀 신입직원 채용`;
        document.getElementById("recruitWorkplace").value = "서울";
        document.getElementById("recruitHiretype").value = "정규직";
        document.getElementById("recruitSalary").value = "350";
        document.getElementById("recruitPosition").value = "연구개발";
        document.getElementById("recruitWorkdetail").value = "웹 UI/UX 개발 및 유지보수";
        document.getElementById("recruitPq").value = "React, Vue.js 경험자 우대";
        document.getElementById("recruitContact").value = "02-123-123";
        document.getElementById("recruitHirenum").value = "0";
        
        const today = new Date();
        const twoWeeksLater = new Date();
        twoWeeksLater.setDate(today.getDate() + 14);
        
        document.getElementById("recruitStartdate").value = formatDate(today);
        document.getElementById("recruitEnddate").value = formatDate(twoWeeksLater);
        
        
        
        
    });

	// 부트스트랩 모달 객체 생성
    const recruitModal = new bootstrap.Modal(document.getElementById("recruitModal"));

 	// 등록 버튼 클릭 시 모달창 띄우기
    document.getElementById("registerModal").addEventListener("click", function() {
        
    	// 모달 내부에 입력했던 데이터 초기화
    	document.querySelectorAll("#recruitModal input, #recruitModal textarea, #recruitModal select")
    		.forEach(el => el.value = "");
    	
    	
    	recruitModal.show();
    });

 	// 등록 처리 (비동기)
    document.getElementById("submitRecruit").addEventListener("click", function() {

    	const fields = [
    		document.getElementById("recruitTitle"),
    		document.getElementById("recruitWorkplace"),
    		document.getElementById("recruitHiretype"),
    		document.getElementById("recruitSalary"),
    		document.getElementById("recruitWorkdetail"),
    		document.getElementById("recruitPq"),
    		document.getElementById("recruitStartdate"),
    		document.getElementById("recruitEnddate"),
    		document.getElementById("recruitContact"),
    		document.getElementById("recruitPosition"),
    		document.getElementById("recruitHirenum")
    	];

    	// 미입력 필드 존재 시 SWalert
    	for (let field of fields) {
            if (!field.value.trim()) {
                Swal.fire("입력 누락", "모든 항목을 기입해야 등록할 수 있습니다.", "warning");
                return;
            }
        }
    	

    	// 등록 확인창 Swal
		Swal.fire({
			title: '채용공고 등록',
			text: "채용공고를 등록하시겠습니까?",
			icon: 'question',
			showCancelButton: true,
			confirmButtonColor: '#3085d6',
			cancelButtonColor: '#aaa',
			confirmButtonText: '등록',
			cancelButtonText: '취소'
		}).then((result) => {
			if(result.isConfirmed) {
				const recruitData = {
		            recruitTitle: document.getElementById("recruitTitle").value,
		            recruitWorkplace: document.getElementById("recruitWorkplace").value,
		            recruitHiretype: document.getElementById("recruitHiretype").value,
		            recruitSalary: document.getElementById("recruitSalary").value,
		            recruitWorkdetail: document.getElementById("recruitWorkdetail").value,
		            recruitPq: document.getElementById("recruitPq").value,
		            recruitStartdate: document.getElementById("recruitStartdate").value,
		            recruitEnddate: document.getElementById("recruitEnddate").value,
		            recruitContact: document.getElementById("recruitContact").value,
		            recruitPosition: document.getElementById("recruitPosition").value,
		            recruitHirenum: document.getElementById("recruitHirenum").value
		        };
				
		        axios.post("/recruit/board/registerProcess", recruitData)
		            .then(response => {
		                if (response.data.success) {
		                	Swal.fire("등록 완료", "채용공고가 성공적으로 등록되었습니다!", "success")
		                        .then(() => {
		                            recruitModal.hide();
		                            location.reload();
		                        });
		                } else {
		                	Swal.fire("등록 실패", response.data.message, "error");
		                }
		            })
		            .catch(error => {
		                console.error("등록 오류:", error);
		                Swal.fire("오류 발생", "등록 중 오류가 발생했습니다.", "error");
		            });
			}
		});
    		
    });


//////////////////////////////////////////////////////////////////////////////////////////////

//상세 조회 모달 & 비동기
    const recruitDetailModal = new bootstrap.Modal(document.getElementById("recruitDetailModal"));
    document.body.addEventListener("click", function(event) {
        if (event.target && event.target.classList.contains("recruit-detail-link")) {
            event.preventDefault();
            const recruitId = event.target.getAttribute("data-recruit-id");

            console.log("클릭한 공고 ID:", recruitId);//////////////////////////////

            axios.get("/recruit/board/detail?recruitId=" + recruitId)
            	.then(response => {

            		console.log("서버 응답 데이터:", response.data); /////////////////

            		const data = response.data.recruitBoardDetail;
            		document.getElementById("modalRecruitTitle").textContent = data.recruitTitle;
                    document.getElementById("modalRecruitWorkplace").textContent = data.recruitWorkplace;
                    document.getElementById("modalRecruitHiretype").textContent = data.recruitHiretype;
                    document.getElementById("modalRecruitSalary").textContent = `월 \${data.recruitSalary}만원`;
                    document.getElementById("modalRecruitWorkdetail").textContent = data.recruitWorkdetail;
                    document.getElementById("modalRecruitPq").textContent = data.recruitPq;
                    document.getElementById("modalRecruitEnddate").textContent = new Date(data.recruitEnddate).toLocaleDateString('en-CA');
                    document.getElementById("modalRecruitStartdate").textContent = new Date(data.recruitStartdate).toLocaleDateString('en-CA');
                    document.getElementById("modalRecruitContact").textContent = data.recruitContact;
                    document.getElementById("modalRecruitPosition").textContent = data.recruitPosition;
                    document.getElementById("modalRecruitHirenum").textContent = `\${data.recruitHirenum}명`;

                 	// 모달에 recruitId 저장
                    document.getElementById("recruitDetailModal").setAttribute("data-recruit-id", recruitId);

                    recruitDetailModal.show();
           		})
           		.catch(error => {
                    console.error("채용공고 상세 조회 오류:", error);
                    alert("채용공고를 불러오는 데 실패했습니다.");
                });
        }
    });

//수정 페이지로 이동
    document.getElementById("updateRecruitBtn").addEventListener("click", function() {
        const recruitId = document.getElementById("recruitDetailModal").getAttribute("data-recruit-id");
        // 수정 페이지로 이동
        window.location.href = `/recruit/board/updateUI?recruitId=\${recruitId}`;
    });


//////////////////////////////////////////////////////////////////////////////////////////////

//'지원자보기' 버튼 마우스오버시 지원자 count 표시
/* 
	document.body.addEventListener("mouseover", function(event) {
	    if (event.target.classList.contains("applicant-button")) {
	        const button = event.target;
	        const applicantCount = button.closest('td').querySelector('.applicant-count').textContent.trim();
	        button.dataset.originalText = button.textContent.trim(); // 원래 텍스트 저장
	        button.textContent = applicantCount + "명";
	    }
	});

	document.body.addEventListener("mouseout", function(event) {
	    if (event.target.classList.contains("applicant-button")) {
	        const button = event.target;
	        button.textContent = button.dataset.originalText; // 원래 텍스트 복원
	    }
	});
 */
	
	
	
	
});

</script>
