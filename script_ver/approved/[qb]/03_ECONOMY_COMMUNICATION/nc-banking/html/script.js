let currentPage = 1;
let itemsPerPage = 10;
let allTransactions = [];
let filteredTransactions = [];
let currentPin = "";
let isChangingPin = false;
let isATMPinMode = false;
let isReplacementCard = false;
let confirmationCallback = null;
let confirmationModalInitialized = false;
let buttonClickInProgress = false; 
let atmPinAttempts = 0;
let loadingCancelled = false;
let loadingTimeout = null;
const MAX_ATM_ATTEMPTS = 3;
const resourceName = GetParentResourceName();
const app = document.getElementById("app");
const loadingScreen = document.getElementById("loading-screen");
const loadingProgress = document.querySelector(".loading-progress");
const playerName = document.getElementById("player-name");
const playerCardName = document.getElementById("player-card-name");
const businessMenuItem = document.getElementById("business-menu-item");
const businessTab = document.getElementById("business");
const depositAmount = document.getElementById("deposit-amount");
const withdrawAmount = document.getElementById("withdraw-amount");
const transferAmount = document.getElementById("transfer-amount");
const transferTarget = document.getElementById("transfer-id");
const transferNote = document.getElementById("transfer-note");
const transferSlider = document.getElementById("transfer-slider");
const societyDepositAmount = document.getElementById("society-deposit-amount");
const societyDepositNote = document.getElementById("society-deposit-note");
const societyWithdrawAmount = document.getElementById("society-withdraw-amount");
const societyWithdrawNote = document.getElementById("society-withdraw-note");
const societyNameElement = document.getElementById("society-name");
const societyBalance = document.getElementById("society-balance"); 
const balanceElement = document.getElementById("balance");
const spendingTotal = document.getElementById("spending-total");

let currentSharedAccountId = null;
let sharedAccounts = [];

Object.defineProperty(String.prototype, 'capitalize', {
    value: function() {
      return this.charAt(0).toUpperCase() + this.slice(1);
    },
    enumerable: false
});

function showConfirmation(title, message, confirmText = "Confirm", isDestructive = true) {
    return new Promise((resolve) => {
        confirmationCallback = resolve;
        
        const modal = document.getElementById("confirmation-modal");
        
        if (!modal) {
            console.error("Modal not found!");
            if (confirm(message)) {
                resolve(true);
            } else {
                resolve(false);
            }
            return;
        }
        
        const titleEl = document.getElementById("confirmation-title");
        const messageEl = document.getElementById("confirmation-message");
        const confirmBtn = document.getElementById("confirmation-confirm");
        
        if (titleEl) titleEl.textContent = title;
        if (messageEl) messageEl.textContent = message;
        if (confirmBtn) confirmBtn.innerHTML = `<i class="fas fa-check"></i> ${confirmText}`;
        
        // Force show the modal
        modal.style.setProperty('display', 'block', 'important');
        modal.style.visibility = "visible";
        modal.style.opacity = "1";
        modal.style.zIndex = "999999";
        modal.style.position = "fixed";
        modal.style.top = "0";
        modal.style.left = "0";
        modal.style.width = "100%";
        modal.style.height = "100%";
        
        console.log("Modal should be visible now");
    });
}

function hideConfirmation() {
    const modal = document.getElementById("confirmation-modal");
    if (modal) {
        modal.style.display = "none";
    }
    buttonClickInProgress = false; // Reset click protection
}

function initializeConfirmationModal() {
    if (confirmationModalInitialized) {
        console.log("Confirmation modal already initialized, skipping...");
        return;
    }
    
    const cancelBtn = document.getElementById("confirmation-cancel");
    const confirmBtn = document.getElementById("confirmation-confirm");
    const modal = document.getElementById("confirmation-modal");
    
    if (!cancelBtn || !confirmBtn || !modal) {
        console.error("Confirmation modal elements not found during initialization");
        return;
    }
    
    // Remove existing event listeners completely by cloning
    const newCancelBtn = cancelBtn.cloneNode(true);
    const newConfirmBtn = confirmBtn.cloneNode(true);
    cancelBtn.parentNode.replaceChild(newCancelBtn, cancelBtn);
    confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);
    
    // Add single event listeners with debouncing
    newCancelBtn.addEventListener("click", function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        if (buttonClickInProgress) return;
        buttonClickInProgress = true;
        
        console.log("Cancel button clicked");
        hideConfirmation();
        if (confirmationCallback) {
            confirmationCallback(false);
            confirmationCallback = null;
        }
    }, { once: false });
    
    newConfirmBtn.addEventListener("click", function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        if (buttonClickInProgress) return;
        buttonClickInProgress = true;
        
        console.log("Confirm button clicked");
        hideConfirmation();
        if (confirmationCallback) {
            confirmationCallback(true);
            confirmationCallback = null;
        }
    }, { once: false });
    
    // Handle modal backdrop click (single listener)
    modal.addEventListener("click", function(event) {
        if (event.target === modal && !buttonClickInProgress) {
            buttonClickInProgress = true;
            hideConfirmation();
            if (confirmationCallback) {
                confirmationCallback(false);
                confirmationCallback = null;
            }
        }
    }, { once: false });
    
    confirmationModalInitialized = true;
    console.log("Confirmation modal initialized successfully");
}

function initializeModals() {
    const createModal = document.getElementById("create-account-modal");
    const createBtn = document.getElementById("create-shared-account-btn");
    
    if (createModal && createBtn) {
        const createClose = createModal.querySelector(".close");
        
        createBtn.addEventListener("click", function() {
            createModal.style.display = "block";
            createModal.style.zIndex = "100000";
            document.body.style.backgroundColor = "transparent";
        });
        
        if (createClose) {
            createClose.addEventListener("click", function() {
                createModal.style.display = "none";
            });
        }
        
        createModal.addEventListener("click", function(event) {
            if (event.target === createModal) {
                createModal.style.display = "none";
            }
        });
    }
    
    const joinModal = document.getElementById("join-account-modal");
    const joinBtn = document.getElementById("join-shared-account-btn");
    
    if (joinModal && joinBtn) {
        const joinClose = joinModal.querySelector(".close");
        
        joinBtn.addEventListener("click", function() {
            joinModal.style.display = "block";
            joinModal.style.zIndex = "100000";
            document.body.style.backgroundColor = "transparent";
        });
        
        if (joinClose) {
            joinClose.addEventListener("click", function() {
                joinModal.style.display = "none";
            });
        }
        
        joinModal.addEventListener("click", function(event) {
            if (event.target === joinModal) {
                joinModal.style.display = "none";
            }
        });
    }
}

document.addEventListener("DOMContentLoaded", function() {
        if (window.bankingSystemInitialized) {
        console.log("Banking system already initialized, skipping...");
        return;
    }
    initializeConfirmationModal();
    initializeModals();
    initializeSharedAccountButtons();
    
    app.style.display = "none";
    loadingScreen.style.display = "none";
    
    const pinModal = document.getElementById("card-pin-modal");
    const pinCloseBtn = pinModal?.querySelector(".close");

    if (pinCloseBtn) {
        pinCloseBtn.addEventListener("click", function(e) {
            e.preventDefault();
            e.stopPropagation();
            hidePinModal();
        });
    }

    if (pinModal) {
        pinModal.addEventListener("click", function(event) {
            // Close modal when clicking outside of modal content
            if (event.target === pinModal) {
                hidePinModal();
            }
        });
    }

document.addEventListener("click", function(event) {
    if (event.target.classList.contains("keypad-btn")) {
        // Prevent event bubbling
        event.preventDefault();
        event.stopPropagation();
        
        const number = event.target.getAttribute("data-number");
        const action = event.target.getAttribute("data-action");
        
        if (number !== null) {
            addPinDigit(number);
        } else if (action === "clear") {
            clearLastPinDigit();
        } else if (action === "confirm") {
            confirmPin();
        }
    }
});
    
    const requestCardBtn = document.getElementById("request-physical-card");
    const changePinBtn = document.getElementById("change-card-pin");

    if (requestCardBtn) {
        requestCardBtn.addEventListener("click", function() {
            requestPhysicalCard();
        });
    }

    if (changePinBtn) {
        changePinBtn.addEventListener("click", function() {
            changeCardPin();
        });
    }

    if (transferSlider && transferAmount) {
        transferSlider.addEventListener("input", function() {
            transferAmount.value = this.value;
        });
        
        transferAmount.addEventListener("input", function() {
            transferSlider.value = this.value;
        });
    }
    
    const typeFilter = document.getElementById("transaction-type-filter");
    const searchFilter = document.getElementById("transaction-search");

    if (typeFilter) {
        typeFilter.addEventListener("change", function(e) {
            applyTransactionFilter(e.target.value);
        });
    }

    if (searchFilter) {
        searchFilter.addEventListener("input", function(e) {
            const search = e.target.value.toLowerCase();
            
            if (!search) {
                const typeFilter = document.getElementById("transaction-type-filter");
                const currentFilter = typeFilter ? typeFilter.value : "all";
                applyTransactionFilter(currentFilter);
                return;
            }
            
            let searchResults = allTransactions.filter(transaction => {
                const text = (
                    String(transaction.type || "") + " " +
                    String(transaction.amount || "") + " " +
                    String(transaction.note || "") + " " +
                    String(transaction.timestamp || "")
                ).toLowerCase();
                
                return text.includes(search);
            });
            
            const typeFilter = document.getElementById("transaction-type-filter");
            const currentFilter = typeFilter ? typeFilter.value.toLowerCase() : "all";
            
            if (currentFilter !== "all") {
                searchResults = searchResults.filter(transaction => {
                    const type = String(transaction.type || "").toLowerCase();
                    return type.includes(currentFilter);
                });
            }
            
            filteredTransactions = searchResults;
            currentPage = 1;
            
            const personalContainer = document.querySelector("#transactions-container .transactions-content");
            const dashboardTxContainer = document.querySelector(".transactions-table tbody");
            
            if (personalContainer) personalContainer.innerHTML = "";
            if (dashboardTxContainer) dashboardTxContainer.innerHTML = "";
            
            const sortedTransactions = [...filteredTransactions].sort((a, b) => {
                return new Date(b.timestamp) - new Date(a.timestamp);
            });
            
            const currentPageTransactions = sortedTransactions.slice(0, itemsPerPage);
            
            for(let i = 0; i < currentPageTransactions.length; i++) {
                addTransaction(currentPageTransactions[i]);
            }
            
            const totalPages = Math.ceil(filteredTransactions.length / itemsPerPage);
            updatePaginationControls(1, totalPages, filteredTransactions.length);
            
            if (currentSharedAccountId) {
                const sharedContainer = document.querySelector("#shared-transactions-container .transactions-content");
                if (sharedContainer) {
                    const transactions = sharedContainer.querySelectorAll(".transaction-item");
                    transactions.forEach(item => {
                        const text = item.textContent.toLowerCase();
                        if (text.includes(search)) {
                            item.style.display = "";
                        } else {
                            item.style.display = "none";
                        }
                    });
                }
            }
        });
    }
    
    initializeTabs();
    initializeSharedAccountButtons();
    
    document.querySelectorAll(".menu-item").forEach(item => {
        if (item.getAttribute("data-tab") === "shared-accounts") {
            item.addEventListener("click", loadSharedAccounts);
        }
    });
    
    document.querySelectorAll(".shared-account-tab").forEach(tab => {
        tab.addEventListener("click", function() {
            const tabName = this.getAttribute("data-tab");
            
            if (tabName && tabName.startsWith("business-")) {
                document.querySelectorAll(".shared-account-tab").forEach(t => t.classList.remove("active"));
                this.classList.add("active");
                
                document.querySelectorAll(".shared-account-tab-content").forEach(content => {
                    content.style.display = "none";
                });
                
                document.getElementById(tabName).style.display = "block";
            }
            else if (tabName && (tabName === "transactions" || tabName === "members" || tabName === "settings")) {
                document.querySelectorAll(".shared-account-tab").forEach(t => t.classList.remove("active"));
                this.classList.add("active");
                
                document.querySelectorAll(".shared-account-tab-content").forEach(content => {
                    content.style.display = "none";
                });
                
                document.getElementById("shared-account-" + tabName).style.display = "block";
            }
        });
    });
    
    const viewAllButton = document.getElementById("view-all-transactions");
    if (viewAllButton) {
        viewAllButton.addEventListener("click", function() {
            const personalTab = document.querySelector(".menu-item[data-tab='personal']");
            if (personalTab) {
                personalTab.click();
                
                setTimeout(() => {
                    const typeFilter = document.getElementById("transaction-type-filter");
                    if (typeFilter) {
                        typeFilter.value = "all";
                        const event = new Event('change');
                        typeFilter.dispatchEvent(event);
                    }
                    
                    const searchFilter = document.getElementById("transaction-search");
                    if (searchFilter) {
                        searchFilter.value = "";
                    }
                }, 500);
            }
        });
    }
});

function initializeSharedAccountButtons() {
    // Check if already initialized
    if (window.sharedAccountButtonsInitialized) {
        console.log("Shared account buttons already initialized, skipping...");
        return;
    }
    
    const backBtn = document.getElementById("back-to-shared-accounts");
    if (backBtn) {
        // Remove existing listeners
        const newBackBtn = backBtn.cloneNode(true);
        backBtn.parentNode.replaceChild(newBackBtn, backBtn);
        newBackBtn.addEventListener("click", showSharedAccountsList, { once: false });
    }
    
    const confirmCreateBtn = document.getElementById("confirm-create-account");
    if (confirmCreateBtn) {
        const newCreateBtn = confirmCreateBtn.cloneNode(true);
        confirmCreateBtn.parentNode.replaceChild(newCreateBtn, confirmCreateBtn);
        newCreateBtn.addEventListener("click", createSharedAccount, { once: false });
    }
    
    const confirmJoinBtn = document.getElementById("confirm-join-account");
    if (confirmJoinBtn) {
        const newJoinBtn = confirmJoinBtn.cloneNode(true);
        confirmJoinBtn.parentNode.replaceChild(newJoinBtn, confirmJoinBtn);
        newJoinBtn.addEventListener("click", joinSharedAccount, { once: false });
    }
    
    // Mark as initialized
    window.sharedAccountButtonsInitialized = true;
    console.log("Shared account buttons initialized successfully");
}

function initializeTabs() {
    document.querySelectorAll(".content-tab").forEach(tab => {
        tab.style.display = "none";
        tab.classList.remove("active");
    });
   
    const dashboardTab = document.getElementById("dashboard");
    dashboardTab.style.display = "block";
    dashboardTab.classList.add("active");
   
    if (document.getElementById("shared-accounts-list-view")) {
        document.getElementById("shared-accounts-list-view").style.display = "block";
    }
    if (document.getElementById("shared-account-detail-view")) {
        document.getElementById("shared-account-detail-view").style.display = "none";
    }
   
    document.querySelectorAll(".shared-account-tab").forEach(tab => {
        tab.classList.remove("active");
    });
    if (document.querySelector(".shared-account-tab[data-tab='transactions']")) {
        document.querySelector(".shared-account-tab[data-tab='transactions']").classList.add("active");
    }
   
    document.querySelectorAll(".shared-account-tab-content").forEach(content => {
        content.style.display = "none";
    });
    if (document.getElementById("shared-account-transactions")) {
        document.getElementById("shared-account-transactions").style.display = "block";
    }
   
    const societyTransactions = document.getElementById("society-transactions-container");
    if (societyTransactions) {
        societyTransactions.style.display = "block";
    }
}

document.querySelectorAll(".menu-item").forEach(item => {
    item.addEventListener("click", function() {
        if (this.classList.contains("logout")) return;
       
        const tabId = this.getAttribute("data-tab");
       
        if (tabId === "business") {
            setTimeout(() => {
                document.querySelectorAll(".shared-account-tab").forEach(tab => tab.classList.remove("active"));
                document.querySelector('.shared-account-tab[data-tab="business-transactions"]').classList.add("active");
                
                document.querySelectorAll(".shared-account-tab-content").forEach(content => {
                    content.style.display = "none";
                });
                document.getElementById("business-transactions").style.display = "block";
            }, 100);
        }
       
        if (tabId === "business") {
            const societyTransactionsContainer = document.getElementById("society-transactions-container");
            if (societyTransactionsContainer) {
                societyTransactionsContainer.style.display = "block";
            }
        }
        
        document.querySelectorAll(".menu-item").forEach(i => i.classList.remove("active"));
        this.classList.add("active");
        
        document.querySelectorAll(".content-tab").forEach(tab => {
            tab.style.opacity = "0";
            tab.classList.remove("active");
            setTimeout(() => {
                tab.style.display = "none";
            }, 300);
        });

        setTimeout(() => {
            const selectedTab = document.getElementById(tabId);
            selectedTab.style.display = "block";
            
            setTimeout(() => {
                selectedTab.style.opacity = "1";
                selectedTab.classList.add("active");
            }, 50);
        }, 300);
    });
});

function sendNativeNotification(message, type) {
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
            action: "sendNotification",
            data: { 
                message: message,
                type: type
            }
        })
    });
}

function sendMessage(action, data) {
    return fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            action,
            data
        })
    });
}

function resetLoadingBar() {
    loadingCancelled = false; // Reset cancellation flag
    app.style.display = "none";
    app.style.opacity = "1";
    loadingScreen.style.display = "flex";
    loadingScreen.style.opacity = "1";
    loadingProgress.style.width = "0";
    loadingProgress.style.transition = "width 2.5s ease-out";
    document.querySelectorAll(".transactions-content").forEach((obj) => {obj.innerHTML = ""});
}

function animateLoadingBar() {
    if (loadingCancelled) return; // Don't start animation if cancelled
    
    requestAnimationFrame(() => {
        setTimeout(() => {
            if (loadingCancelled) return; // Check again before starting progress
            loadingProgress.style.width = "100%";
        }, 100);

        loadingTimeout = setTimeout(() => {
            if (loadingCancelled) return; // Check before finishing loading
            
            loadingScreen.style.transition = "opacity 0.5s ease-out";
            loadingScreen.style.opacity = "0";
            
            setTimeout(() => {
                if (loadingCancelled) return; // Final check before showing app
                
                loadingScreen.style.display = "none";
                loadingProgress.style.transition = "none";
                loadingProgress.style.width = "0";
                app.style.display = "flex";
                app.style.animation = "fadeIn 0.5s ease-out";
            }, 500);
        }, 2600);
    });
}

function updateSpendingChart(transactions = null, serverSpending = null) {
    const bars = document.querySelectorAll('.chart-bar');
    if (!bars || bars.length === 0) return;
    
    let dailySpending = {
        0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0
    };
    
    if (serverSpending && typeof serverSpending === 'object') {
        dailySpending = serverSpending;
    } else if (typeof serverSpending === 'number') {
        const today = new Date().getDay();
        const baseDailyAmount = serverSpending / 7;
        for (let i = 0; i < 7; i++) {
            const variation = 0.5 + (Math.random() * 1.0);
            dailySpending[i] = Math.floor(baseDailyAmount * variation);
        }
        dailySpending[today] = Math.floor(serverSpending * 0.25);
    }
    
    const today = new Date().getDay();
    const todaySpending = dailySpending[today] || 0;
    
    const spendingTotal = document.getElementById('spending-total');
    const spendingLabel = document.querySelector('.spending-label');
    
    if (spendingTotal) {
        spendingTotal.textContent = Math.abs(todaySpending).toLocaleString();
        
        spendingTotal.parentElement.classList.remove('positive', 'negative');
        if (todaySpending > 0) {
            spendingLabel.textContent = "Net Income";
            spendingTotal.parentElement.classList.add('positive');
        } else if (todaySpending < 0) {
            spendingLabel.textContent = "Net Spending";
            spendingTotal.parentElement.classList.add('negative');
        } else {
            spendingLabel.textContent = "No Activity";
        }
        
        spendingTotal.parentElement.classList.add('updating');
        setTimeout(() => {
            spendingTotal.parentElement.classList.remove('updating');
        }, 500);
    }
    
    let maxSpending = Math.max(...Object.values(dailySpending).map(val => Math.abs(val)));
    if (maxSpending === 0) {
        maxSpending = 100;
    }
    
    bars.forEach((bar, index) => {
        bar.classList.remove('active', 'positive', 'negative');
        
        const daySpending = dailySpending[index] || 0;
        
        let heightPercent = 4;
        if (maxSpending > 0 && daySpending !== 0) {
            heightPercent = Math.min(85, Math.max(8, (Math.abs(daySpending) / maxSpending) * 75));
        }
        
        bar.style.height = heightPercent + '%';
        bar.style.margin = '0 2px';
        
        if (daySpending > 0) {
            bar.classList.add('positive');
            bar.style.background = 'rgba(27, 188, 157, 0.6)';
            bar.setAttribute('data-amount', '+$' + Math.abs(daySpending).toLocaleString());
        } else if (daySpending < 0) {
            bar.classList.add('negative');  
            bar.style.background = 'rgba(255, 85, 85, 0.6)';
            bar.setAttribute('data-amount', '-$' + Math.abs(daySpending).toLocaleString());
        } else {
            bar.style.background = 'rgba(27, 188, 157, 0.1)';
            bar.setAttribute('data-amount', '$0');
        }
        
        if (index === today) {
            bar.classList.add('active');
        }
    });
    
    const dayLabels = document.querySelectorAll('.x-label');
    if (dayLabels) {
        dayLabels.forEach((label, index) => {
            label.classList.remove('active');
            if (index === today) {
                label.classList.add('active');
            }
        });
    }
    
    updateYAxisLabels(maxSpending);
}

function updatePaginationControls(page, totalPages, totalItems) {
    const prevBtn = document.getElementById("prev-page");
    const nextBtn = document.getElementById("next-page");
    const pageIndicator = document.getElementById("page-indicator");
    
    if (!prevBtn || !nextBtn || !pageIndicator) return;
    
    if (totalPages > 0) {
        pageIndicator.textContent = `Page ${page} of ${totalPages} (${totalItems} total)`;
    } else {
        pageIndicator.textContent = "No transactions";
    }
    
    prevBtn.disabled = page <= 1;
    nextBtn.disabled = page >= totalPages;
    
    prevBtn.onclick = () => goToPage(page - 1);
    nextBtn.onclick = () => goToPage(page + 1);
    
    if (prevBtn.disabled) {
        prevBtn.style.opacity = "0.5";
        prevBtn.style.cursor = "not-allowed";
    } else {
        prevBtn.style.opacity = "1";
        prevBtn.style.cursor = "pointer";
    }
    
    if (nextBtn.disabled) {
        nextBtn.style.opacity = "0.5";
        nextBtn.style.cursor = "not-allowed";
    } else {
        nextBtn.style.opacity = "1";
        nextBtn.style.cursor = "pointer";
    }
}

function goToPage(page) {
    const totalPages = Math.ceil(filteredTransactions.length / itemsPerPage);
    
    if (page < 1 || page > totalPages) return;
    
    currentPage = page;
    
    const personalContainer = document.querySelector("#transactions-container .transactions-content");
    const dashboardTxContainer = document.querySelector(".transactions-table tbody");
    
    if (personalContainer) personalContainer.innerHTML = "";
    if (dashboardTxContainer) dashboardTxContainer.innerHTML = "";
    
    const sortedTransactions = [...filteredTransactions].sort((a, b) => {
        return new Date(b.timestamp) - new Date(a.timestamp);
    });
    
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const currentPageTransactions = sortedTransactions.slice(startIndex, endIndex);
    
    for(let i = 0; i < currentPageTransactions.length; i++) {
        addTransaction(currentPageTransactions[i]);
    }
    
    updatePaginationControls(currentPage, Math.ceil(filteredTransactions.length / itemsPerPage), filteredTransactions.length);
    
    const transactionsSection = document.querySelector(".transactions-section");
    if (transactionsSection) {
        transactionsSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
}

function applyTransactionFilter(filterValue) {
    const filter = filterValue.toLowerCase();
    
    if (filter === "all") {
        filteredTransactions = [...allTransactions];
    } else {
        filteredTransactions = allTransactions.filter(transaction => {
            const type = String(transaction.type || "").toLowerCase();
            return type.includes(filter);
        });
    }
    
    currentPage = 1;
    
    const isSocietyTransaction = filteredTransactions.length > 0 && filteredTransactions[0].society;
    
    if (!isSocietyTransaction) {
        const personalContainer = document.querySelector("#transactions-container .transactions-content");
        const dashboardTxContainer = document.querySelector(".transactions-table tbody");
        
        if (personalContainer) personalContainer.innerHTML = "";
        if (dashboardTxContainer) dashboardTxContainer.innerHTML = "";
        
        const sortedTransactions = [...filteredTransactions].sort((a, b) => {
            return new Date(b.timestamp) - new Date(a.timestamp);
        });
        
        const currentPageTransactions = sortedTransactions.slice(0, itemsPerPage);
        
        for(let i = 0; i < currentPageTransactions.length; i++) {
            addTransaction(currentPageTransactions[i]);
        }
        
        const totalPages = Math.ceil(filteredTransactions.length / itemsPerPage);
        updatePaginationControls(1, totalPages, filteredTransactions.length);
    }
}

function updateYAxisLabels(maxAmount) {
    const yLabels = document.querySelectorAll('.y-label');
    if (!yLabels || yLabels.length === 0) return;
    
    const steps = [
        Math.ceil(maxAmount * 1.2),
        Math.ceil(maxAmount * 0.8),
        Math.ceil(maxAmount * 0.4),
        0
    ];
    
    yLabels.forEach((label, index) => {
        if (steps[index] >= 1000) {
            label.textContent = Math.floor(steps[index] / 1000) + 'K';
        } else {
            label.textContent = steps[index].toString();
        }
    });
}

function toggleSociety(societyData) {
    if(societyData.isBoss) {
        updateSocietyInfo(societyData.name, societyData.balance);
        businessMenuItem.style.display = "block";
    } else {
        businessMenuItem.style.display = "none";
    }
}

const addTransactions = (transactions) => {
    allTransactions = [...transactions];
    filteredTransactions = [...transactions];
    
    currentPage = 1;
    
    const isSocietyTransaction = transactions.length > 0 && transactions[0].society;
    
    if (isSocietyTransaction) {
        const societyContainer = document.querySelector("#society-transactions-container .transactions-content");
        if (societyContainer) societyContainer.innerHTML = "";
    } else {
        const personalContainer = document.querySelector("#transactions-container .transactions-content");
        if (personalContainer) personalContainer.innerHTML = "";
        
        const dashboardTxContainer = document.querySelector(".transactions-table tbody");
        if (dashboardTxContainer) dashboardTxContainer.innerHTML = "";
    }
    
    const sortedTransactions = [...filteredTransactions].sort((a, b) => {
        return new Date(b.timestamp) - new Date(a.timestamp);
    });
    
    if (!isSocietyTransaction) {
        const totalItems = sortedTransactions.length;
        const totalPages = Math.ceil(totalItems / itemsPerPage);
        const startIndex = (currentPage - 1) * itemsPerPage;
        const endIndex = startIndex + itemsPerPage;
        const currentPageTransactions = sortedTransactions.slice(startIndex, endIndex);
        
        for(let i = 0; i < currentPageTransactions.length; i++) {
            addTransaction(currentPageTransactions[i]);
        }
        
        updatePaginationControls(currentPage, totalPages, totalItems);
    } else {
        for(let i = 0; i < sortedTransactions.length; i++) {
            addTransaction(sortedTransactions[i]);
        }
    }
    
    const currentFilter = document.getElementById("transaction-type-filter");
    if (currentFilter && currentFilter.value !== "all") {
        if (!isSocietyTransaction) {
            applyTransactionFilter(currentFilter.value);
        } else {
            const filter = currentFilter.value.toLowerCase();
            const societyContainer = document.querySelector("#society-transactions-container .transactions-content");
            
            if (societyContainer) {
                const transactions = societyContainer.querySelectorAll(".transaction-item");
                transactions.forEach(item => {
                    const type = item.querySelector(".transaction-type");
                    if (type) {
                        const typeText = type.textContent.toLowerCase();
                        if (filter === "all" || typeText.includes(filter)) {
                            item.style.display = "";
                        } else {
                            item.style.display = "none";
                        }
                    }
                });
            }
        }
    }
}

const ACTIONS = {
"open": (data) => {
    resetLoadingBar();
    
    playerName.textContent = data.playerName;
    if (playerCardName) playerCardName.textContent = data.playerName;
    updateBalance(data.bankBalance);
    
    const requestCardBtn = document.getElementById("request-physical-card");
    const changePinBtn = document.getElementById("change-card-pin");
    
    if (data.cardStatus) {
        updateCardButtons(data.cardStatus);
    } else {
        if (requestCardBtn) requestCardBtn.style.display = "inline-flex";
        if (changePinBtn) changePinBtn.style.display = "none";
    }
            
    if (data.creditScore) {
        const creditScoreElement = document.querySelector('.credit-score-number');
        if (creditScoreElement) {
            creditScoreElement.textContent = data.creditScore;
        }
    }
    
    if (spendingTotal) {
        if (data.dailySpending) {
            updateSpendingChart(data.transactions, data.dailySpending);
        } else if (data.weeklySpending) {
            updateSpendingChart(data.transactions, data.weeklySpending);
        }
    }
    
    document.querySelectorAll(".transactions-content").forEach((obj) => {obj.innerHTML = ""});
    
    addTransactions(data.transactions);
    
    document.querySelectorAll(".menu-item").forEach(i => i.classList.remove("active"));
    document.querySelector(".menu-item[data-tab='dashboard']").classList.add("active");
    
    document.querySelectorAll(".content-tab").forEach(tab => {
        tab.style.display = "none";
        tab.classList.remove("active");
    });
    
    const dashboardTab = document.getElementById("dashboard");
    dashboardTab.style.display = "block";
    dashboardTab.classList.add("active");
    dashboardTab.style.opacity = "1";
    
    if (transferSlider && data.bankBalance > 0) {
        const max = Math.min(data.bankBalance, 100000);
        transferSlider.max = max;
        transferSlider.value = Math.floor(max / 2);
        if (transferAmount) transferAmount.value = transferSlider.value;
    }
    
    if (data.isATM) {
        document.querySelector(".banking-container").classList.add("atm-mode");
        businessMenuItem.style.display = "none";
    } else {
        document.querySelector(".banking-container").classList.remove("atm-mode");
        toggleSociety(data.society);
    }
    
    if (data.society && data.society.isBoss) {
        const societyContainer = document.querySelector("#society-transactions-container .transactions-content");
        if (societyContainer && (!societyContainer.children.length || societyContainer.children.length === 0)) {
            fetch(`https://${resourceName}/action`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ 
                    action: "getSocietyTransactions",
                    data: { refresh: true }
                })
            });
        }
    }
    
    setTimeout(() => {
        document.querySelectorAll("#dashboard *").forEach(el => {
            el.style.transition = "none";
            void el.offsetWidth;
            el.style.transition = "";
        });
    }, 100);
    
    animateLoadingBar();
},

"updateDailySpending": (data) => {
    if (data.dailySpending) {
        updateSpendingChart(null, data.dailySpending);
    }
},

"updateCreditScore": (data) => {
    if (data.creditScore) {
        const creditScoreElement = document.querySelector('.credit-score-number');
        if (creditScoreElement) {
            const currentScore = parseInt(creditScoreElement.textContent) || 130;
            animateNumber(creditScoreElement, currentScore, data.creditScore);
        }
    }
},

"subtractFromChart": (data) => {
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
            action: "refreshDailySpending"
        })
    });
},

"close": (data) => {
    app.style.animation = "fadeOut 0.3s ease-out";
    setTimeout(() => {
        app.style.display = "none";
        loadingScreen.style.display = "none";
        loadingScreen.style.opacity = "1";
        loadingProgress.style.width = "0";
        loadingProgress.style.transition = "none";
        
        document.querySelector(".banking-container").classList.remove("atm-mode");
    }, 300);
},

"updateBalance": (data) => {
    updateBalance(data.newBalance);
    
    if (transferSlider) {
        const max = Math.min(data.newBalance, 100000);
        transferSlider.max = max;
    }
},

"updateSocietyBalance": (data) => {
    updateSocietyInfo(null, data.newBalance);
},

    "requestATMPin": (data) => {
        console.log("=== ATM PIN REQUEST RECEIVED ===");
        atmPinAttempts = 0;
        isATMPinMode = true;
        isChangingPin = false;
        isReplacementCard = false;
        
        document.getElementById("pin-modal-title").textContent = "Enter Your PIN";
        document.getElementById("pin-modal-description").textContent = "Enter your 4-digit card PIN to access ATM";
        
        const pinFeeElement = document.querySelector(".pin-fee");
        if (pinFeeElement) {
            pinFeeElement.style.display = "none";
        }
        
        showPinModal();
    },


"atmPinVerified": (data) => {
    console.log("ATM PIN verified - opening bank");
    isATMPinMode = false;
    hidePinModal();
    
    // Open bank immediately without delay
    console.log("Triggering bank open after PIN verification");
    sendMessage("openBankAfterPin", { isATM: true });
},
    "atmPinFailed": (data) => {
        console.log("ATM PIN failed:", data.message);
        
        // Show error and reset PIN input
        currentPin = "";
        updatePinDots();
        updatePinConfirmButton();
        
        // Show error message in the PIN modal
        showPinError(data.message || "Invalid PIN");
        
        // Increment attempts counter
        atmPinAttempts++;
        
        // If too many attempts, close modal and show notification
        if (atmPinAttempts >= MAX_ATM_ATTEMPTS || (data.message && data.message.includes("blocked"))) {
            setTimeout(() => {
                isATMPinMode = false;
                hidePinModal();
                sendNativeNotification(data.message || "Too many failed attempts", "error");
                // Send close message to client to handle NUI focus
                sendMessage("close");
            }, 2000);
        }
    },
"cardIssued": (data) => {
    const requestCardBtn = document.getElementById("request-physical-card");
    const changePinBtn = document.getElementById("change-card-pin");
    
    if (requestCardBtn && changePinBtn) {
        requestCardBtn.style.display = "none";
        changePinBtn.style.display = "inline-flex";
        changePinBtn.innerHTML = '<i class="fas fa-key"></i> Change PIN';
        changePinBtn.onclick = function() {
            changeCardPin();
        };
    }
},

"updateTransactions": (data) => {
    const personalContainer = document.querySelector("#transactions-container .transactions-content");
    if (personalContainer) {
        personalContainer.innerHTML = "";
    }
    
    const dashboardTxContainer = document.querySelector(".transactions-table tbody");
    if (dashboardTxContainer) {
        dashboardTxContainer.innerHTML = "";
    }
    
    if (data.transactions) {
        allTransactions = [...data.transactions];
        filteredTransactions = [...data.transactions];
        
        const sortedTransactions = [...filteredTransactions].sort((a, b) => {
            return new Date(b.timestamp) - new Date(a.timestamp);
        });
        
        const totalItems = sortedTransactions.length;
        const totalPages = Math.ceil(totalItems / itemsPerPage);
        const startIndex = (currentPage - 1) * itemsPerPage;
        const endIndex = startIndex + itemsPerPage;
        const currentPageTransactions = sortedTransactions.slice(startIndex, endIndex);
        
        for(let i = 0; i < currentPageTransactions.length; i++) {
            const tx = {...currentPageTransactions[i]};
            tx.society = false;
            addTransaction(tx);
        }
        
        updatePaginationControls(currentPage, totalPages, totalItems);
        updateSpendingChart(data.transactions);
    }
    
    if (currentSharedAccountId) {
        fetch(`https://${resourceName}/action`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ 
                action: "getSharedAccountDetails",
                data: { accountId: currentSharedAccountId }
            })
        })
        .then(response => response.json())
        .then(account => {
            if (account && account.transactions) {
                renderTransactions(account.transactions);
            }
        });
    }
},

"renderTransactions": (data) => {
    if (data.transactions) {
        renderTransactions(data.transactions);
    }
},

"refreshSharedAccounts": (data) => {
    refreshAllSharedAccounts();
},

"clearTransactions": (data) => {
    document.querySelectorAll(".transactions-content").forEach((obj) => {obj.innerHTML = ""});
},

"updateSocietyTransactions": (data) => {
    if (!data || !Array.isArray(data.transactions)) {
        return;
    }
    
    const societyContainer = document.querySelector("#society-transactions-container .transactions-content");
    if (societyContainer) {
        societyContainer.innerHTML = "";
        
        if (data.transactions.length === 0) {
            societyContainer.innerHTML = `<div class="no-transactions-message">No society transactions yet</div>`;
            return;
        }
        
        if (typeof updateBusinessRecentActivity === 'function') {
            updateBusinessRecentActivity(data.transactions);
        }
        
        const businessNameDisplay = document.getElementById("business-name-display");
        if (businessNameDisplay && typeof societyNameElement !== 'undefined') {
            businessNameDisplay.textContent = societyNameElement.textContent;
        }
    } else {
        return;
    }
    
    for(let i = 0; i < data.transactions.length; i++) {
        const tx = {...data.transactions[i], society: true};
        addTransaction(tx);
    }
},

"removeRequest": (data) => {
    const requestElement = document.querySelector(`.request-item[data-request-id="${data.requestId}"]`);
    if (requestElement) {
        requestElement.remove();
        
        const container = document.getElementById("pending-requests-container");
        if (container && container.querySelector('.request-item') === null) {
            container.innerHTML = `<div class="no-requests-message">No pending requests</div>`;
        }
    }
},

"clearAllTransactions": (data) => {
    const personalContainer = document.querySelector("#transactions-container .transactions-content");
    if (personalContainer) {
        personalContainer.innerHTML = "";
    }
    
    const societyContainer = document.querySelector("#society-transactions-container .transactions-content");
    if (societyContainer) {
        societyContainer.innerHTML = "";
    }
    
    const sharedContainer = document.querySelector("#shared-transactions-container .transactions-content");
    if (sharedContainer) {
        sharedContainer.innerHTML = "";
    }
    
    const dashboardTxContainer = document.querySelector(".transactions-table tbody");
    if (dashboardTxContainer) {
        dashboardTxContainer.innerHTML = "";
    }
},

"updateSharedAccountTransactions": (data) => {
    if (!data.transactions) return;
        
    const container = document.querySelector("#shared-transactions-container .transactions-content");
    if (container) {
        container.innerHTML = "";
        
        if (data.transactions.length === 0) {
            container.innerHTML = `<div class="no-transactions-message">No transactions yet</div>`;
            return;
        }
        
        data.transactions.forEach(tx => {
            tx.shared = true;
            renderTransactions(data.transactions);
        });
    }
},

"updateSharedAccountBalance": (data) => {
    const accountId = data.accountId;
    const newBalance = data.newBalance;
    
    if (currentSharedAccountId === accountId) {
        const balanceElement = document.getElementById("shared-account-balance");
        if (balanceElement) {
            const currentBalance = parseInt(balanceElement.textContent.replace(/,/g, "")) || 0;
            animateNumber(balanceElement, currentBalance, newBalance);
        }
    }
    
    if (typeof sharedAccounts !== 'undefined') {
        const account = sharedAccounts.find(acc => acc.id === accountId);
        if (account) {
            account.balance = newBalance;
            if (!currentSharedAccountId && typeof renderSharedAccountsList === 'function') {
                renderSharedAccountsList();
            }
        }
    }
},

"updateSharedAccountCode": (data) => {
    const accountId = data.accountId;
    const newCode = data.newCode;
    
    if (currentSharedAccountId === accountId) {
        const sharedAccountCodeElement = document.getElementById("shared-account-code");
        const accountCodeDisplayElement = document.getElementById("account-code-display");
        
        if (sharedAccountCodeElement) {
            sharedAccountCodeElement.textContent = newCode;
        }
        if (accountCodeDisplayElement) {
            accountCodeDisplayElement.textContent = newCode;
        }
    }
    
    if (typeof sharedAccounts !== 'undefined') {
        const account = sharedAccounts.find(acc => acc.id === accountId);
        if (account) {
            account.code = newCode;
        }
    }
}
};

const closeUI = () => {
    // Cancel loading if in progress
    loadingCancelled = true;
    if (loadingTimeout) {
        clearTimeout(loadingTimeout);
        loadingTimeout = null;
    }
    
    app.style.opacity = "0";
    loadingScreen.style.display = "none"; // Hide loading screen immediately
    sendMessage("close");
    
    setTimeout(() => {
        app.style.display = "none";
        loadingScreen.style.opacity = "1";
        loadingProgress.style.width = "0";
        loadingProgress.style.transition = "none";
    }, 300);
}

const PlayerActionsElements = {
    "deposit": depositAmount,
    "withdraw": withdrawAmount,
    "transfer": transferAmount
}

const playerAction = (action) => {
    const amount = parseInt(PlayerActionsElements[action].value);
    let additionalData = {};

    if(isNaN(amount) || amount <= 0) {
        PlayerActionsElements[action].classList.add("error");
        setTimeout(() => {
            PlayerActionsElements[action].classList.remove("error");
        }, 500);
        return;
    }

    if(action == "transfer") {
        if(!transferTarget.value.trim()) {
            transferTarget.classList.add("error");
            setTimeout(() => {
                transferTarget.classList.remove("error");
            }, 500);
            return;
        }
        
        additionalData = {
            target: transferTarget.value,
            note: transferNote.value
        }

        transferNote.value = "";
        transferTarget.value = "";
    } else if(action == "deposit") {
        const noteInput = document.getElementById("deposit-note");
        if(noteInput) {
            additionalData = {
                note: noteInput.value
            }
            noteInput.value = "";
        }
        
        handleDeposit(amount);
    } else if(action == "withdraw") {
        const noteInput = document.getElementById("withdraw-note");
        if(noteInput) {
            additionalData = {
                note: noteInput.value
            }
            noteInput.value = "";
        }
        
        handleWithdraw(amount);
    }

    PlayerActionsElements[action].value = "";
    animateButton(document.querySelector(`.${action} button`) || document.querySelector(`.transfer-btn`));
    
    sendMessage(action, {
        amount: parseInt(amount),
        ...additionalData
    })
}

const SocietyElements = {
    "deposit": [societyDepositAmount, societyDepositNote],
    "withdraw": [societyWithdrawAmount, societyWithdrawNote]
}

const societyAction = (action) => {
    const [amountElement, noteElement] = SocietyElements[action];
    
    const amount = parseInt(amountElement.value);

    if(isNaN(amount) || amount <= 0) {
        amountElement.classList.add("error");
        setTimeout(() => {
            amountElement.classList.remove("error");
        }, 500);
        return;
    }
    
    sendMessage("society" + (action.capitalize()), {
        amount,
        note: noteElement.value
    })
    
    amountElement.value = ""
    noteElement.value = ""
    
    animateButton(amountElement.closest('.action-card').querySelector('button'));
}

function updateBalance(amount) {
    animateNumber(balanceElement, parseInt(balanceElement.textContent.replace(/,/g, "")), amount);
    
    if (transferSlider) {
        const max = Math.min(amount, 100000);
        transferSlider.max = max;
    }
    
    const spendingAmount = Math.floor(amount * 0.7);
    const spendingTotal = document.getElementById('spending-total');
    if (spendingTotal) {
        spendingTotal.textContent = spendingAmount.toLocaleString();
    }
    updateSpendingChart(spendingAmount);
}

function updateSocietyInfo(societyName, money) {
    animateNumber(societyBalance, parseInt(societyBalance.textContent.replace(/,/g, "")), money);
    
    if (societyName) {
        societyNameElement.textContent = societyName.capitalize();
    }
}

function animateButton(button) {
    if (!button) return;
    
    button.style.transform = "scale(0.95)";
    button.style.boxShadow = "0 2px 8px rgba(27, 188, 157, 0.5)";
    
    setTimeout(() => {
        button.style.transform = "scale(1)";
        button.style.boxShadow = "";
    }, 200);
}

function animateNumber(element, start, end) {
    if (!element) return;
    
    const duration = 1000;
    const startTime = performance.now();
    
    function update() {
        const currentTime = performance.now();
        const progress = Math.min((currentTime - startTime) / duration, 1);
        
        const current = Math.floor(start + (end - start) * progress);
        element.textContent = current.toLocaleString();
        
        if (progress < 1) {
            requestAnimationFrame(update);
        } else {
            element.style.transform = "scale(1.05)";
            setTimeout(() => {
                element.style.transform = "scale(1)";
            }, 100);
        }
    }
    
    requestAnimationFrame(update);
}

function formatTransactionType(type) {
    if (!type) return "Unknown";
    
    const typeStr = String(type);
    
    const typeMap = {
        "1": "Deposit",
        "2": "Withdraw",
        "3": "Society Deposit",
        "4": "Society Withdraw",
        "5": "Transfer",
        "6": "Shared Deposit",
        "7": "Shared Withdraw",
        "8": "Shared Transfer",
        
        "deposit": "Deposit",
        "withdraw": "Withdraw",
        "society_deposit": "Society Deposit",
        "society_withdraw": "Society Withdraw",
        "transfer": "Transfer",
        "shared_deposit": "Shared Deposit",
        "shared_withdraw": "Shared Withdraw",
        "shared_transfer": "Shared Transfer"
    };
    
    if (typeMap[typeStr.toLowerCase()]) {
        return typeMap[typeStr.toLowerCase()];
    }
    
    if (typeStr.includes('_')) {
        const parts = typeStr.split('_');
        return parts.map(part => part.charAt(0).toUpperCase() + part.slice(1)).join(' ');
    }
    
    if (!isNaN(typeStr)) {
        return "Unknown " + typeStr;
    }
    
    return typeStr.charAt(0).toUpperCase() + typeStr.slice(1);
}

function addTransaction(transaction) {
    const containerSelector = transaction.society ? "#society-transactions-container" : "#transactions-container";
    const container = document.querySelector(`${containerSelector} .transactions-content`);
    
    if (!container) return;
    
    const dashboardTxContainer = document.querySelector(".transactions-table tbody");
    
    const transactionElement = document.createElement("div");
    transactionElement.className = "transaction-item";
    
    let txType = String(transaction.type || "").toLowerCase();
    
    let typeDisplay = "Unknown";
    let typeIcon = "fa-exchange-alt";
    let typeClass = "unknown";
    let status = "Completed";
    
    if (!isNaN(txType)) {
        const numType = parseInt(txType);
        switch(numType) {
            case 1: txType = "deposit"; break;
            case 2: txType = "withdraw"; break;
            case 3: txType = "society_deposit"; break;
            case 4: txType = "society_withdraw"; break;
            case 5: txType = "transfer"; break;
            case 6: txType = "shared_deposit"; break;
            case 7: txType = "shared_withdraw"; break;
            case 8: txType = "shared_transfer"; break;
        }
    }
    
    if (txType.includes("deposit")) {
        typeIcon = "fa-arrow-down";
        typeClass = "deposit";
        if (txType.includes("society")) {
            typeDisplay = "Society Deposit";
        } else if (txType.includes("shared")) {
            typeDisplay = "Shared Deposit";
        } else {
            typeDisplay = "Deposit";
        }
    } else if (txType.includes("withdraw")) {
        typeIcon = "fa-arrow-up";
        typeClass = "withdraw";
        if (txType.includes("society")) {
            typeDisplay = "Society Withdraw";
        } else if (txType.includes("shared")) {
            typeDisplay = "Shared Withdraw";
        } else {
            typeDisplay = "Withdraw";
        }
    } else if (txType.includes("transfer")) {
        typeIcon = "fa-paper-plane";
        typeClass = "transfer";
        if (txType.includes("shared")) {
            typeDisplay = "Shared Transfer";
        } else {
            typeDisplay = "Transfer";
        }
    } else if (txType.includes("unknown")) {
        const match = txType.match(/unknown_(\d+)/);
        if (match && match[1]) {
            const numType = parseInt(match[1]);
            switch(numType) {
                case 1: typeDisplay = "Deposit"; typeIcon = "fa-arrow-down"; typeClass = "deposit"; break;
                case 2: typeDisplay = "Withdraw"; typeIcon = "fa-arrow-up"; typeClass = "withdraw"; break;
                case 3: typeDisplay = "Society Deposit"; typeIcon = "fa-arrow-down"; typeClass = "deposit"; break;
                case 4: typeDisplay = "Society Withdraw"; typeIcon = "fa-arrow-up"; typeClass = "withdraw"; break;
                case 5: typeDisplay = "Transfer"; typeIcon = "fa-paper-plane"; typeClass = "transfer"; break;
                case 6: typeDisplay = "Shared Deposit"; typeIcon = "fa-arrow-down"; typeClass = "deposit"; break;
                case 7: typeDisplay = "Shared Withdraw"; typeIcon = "fa-arrow-up"; typeClass = "withdraw"; break;
                case 8: typeDisplay = "Shared Transfer"; typeIcon = "fa-paper-plane"; typeClass = "transfer"; break;
                default: typeDisplay = "Unknown " + numType;
            }
        }
    }
    
    let formattedDate;
    try {
        formattedDate = new Date(transaction.timestamp).toLocaleString();
    } catch (e) {
        formattedDate = "Unknown date";
    }
    
    transactionElement.innerHTML = `
        <div class="transaction-type ${typeClass}">
            <i class="fas ${typeIcon}"></i>
            ${typeDisplay}
        </div>
        <div class="transaction-amount ${transaction.amount < 0 ? "negative" : ""}">
            ${transaction.amount < 0 ? "-" : "+"}${Math.abs(transaction.amount).toLocaleString()}
        </div>
        <div class="transaction-note">${transaction.note || "-"}</div>
        <div class="transaction-date">${formattedDate}</div>
    `;
    
    transactionElement.style.opacity = "0";
    transactionElement.style.transform = "translateY(-10px)";
    
    container.appendChild(transactionElement);
    
    if (!transaction.society && dashboardTxContainer && !transaction.shared) {
        const dashboardTx = document.createElement("tr");
        dashboardTx.innerHTML = `
            <td>
                <div class="transaction-type ${typeClass}">
                    <i class="fas ${typeIcon}"></i>
                    ${typeDisplay}
                </div>
            </td>
            <td class="transaction-amount ${transaction.amount < 0 ? "negative" : ""}">
                ${transaction.amount < 0 ? "-" : "+"}${Math.abs(transaction.amount).toLocaleString()}
            </td>
            <td><span class="transaction-status">${status}</span></td>
            <td>${formattedDate}</td>
        `;
        
        dashboardTxContainer.appendChild(dashboardTx);
    }
    
    setTimeout(() => {
        transactionElement.style.opacity = "1";
        transactionElement.style.transform = "translateY(0)";
    }, 50);
}

function loadSharedAccounts() {
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action: "getSharedAccounts" })
    })
    .then(response => response.json())
    .then(data => {
        sharedAccounts = data;
        renderSharedAccountsList();
    });
}

function updateBusinessRecentActivity(transactions) {
    const activityList = document.getElementById('business-recent-activity-list');
    if (!activityList) return;
    
    if (!transactions || transactions.length === 0) {
        activityList.innerHTML = '<div class="no-activity">No recent activity</div>';
        return;
    }
    
    const recentTransactions = transactions.slice(0, 5);
    activityList.innerHTML = '';
    
    recentTransactions.forEach(tx => {
        const activityItem = document.createElement('div');
        activityItem.className = 'activity-item';
        
        let iconClass = 'deposit';
        let iconSymbol = 'fa-arrow-down';
        let activityText = 'Deposit';
        let amountClass = 'positive';
        let amountPrefix = '+';
        
        const txType = String(tx.type || '').toLowerCase();
        
        if (txType.includes('withdraw')) {
            iconClass = 'withdraw';
            iconSymbol = 'fa-arrow-up';
            activityText = 'Withdraw';
            amountClass = 'negative';
            amountPrefix = '-';
        }
        
        const timeAgo = getTimeAgo(tx.timestamp);
        
        activityItem.innerHTML = `
            <div class="activity-icon ${iconClass}">
                <i class="fas ${iconSymbol}"></i>
            </div>
            <div class="activity-content">
                <div class="activity-text">${activityText}</div>
                <div class="activity-time">${timeAgo}</div>
            </div>
            <div class="activity-amount ${amountClass}">
                ${amountPrefix}$${Math.abs(tx.amount).toLocaleString()}
            </div>
        `;
        
        activityList.appendChild(activityItem);
    });
}

function renderSharedAccountsList() {
    const container = document.getElementById("shared-accounts-container");
    if (!container) return;
    
    container.innerHTML = "";
    
    if (!sharedAccounts || sharedAccounts.length === 0) {
        container.innerHTML = `<div class="no-accounts-message">You don't have any shared accounts yet.</div>`;
        return;
    }
    
    const template = document.getElementById("shared-account-card-template");
    if (!template) return;
    
    sharedAccounts.forEach(account => {
        const card = template.content.cloneNode(true);
        
        card.querySelector(".account-name").textContent = account.name;
        card.querySelector(".balance-value").textContent = account.balance.toLocaleString();
        card.querySelector(".account-code").textContent = `Code: ${account.code}`;
        card.querySelector(".member-count").textContent = `${account.memberCount} members`;
        
        if (account.isOwner) {
            card.querySelector(".owner-badge").style.display = "inline-block";
            
            if (account.pendingRequests > 0) {
                const badge = document.createElement("span");
                badge.classList.add("pending-badge");
                badge.textContent = `${account.pendingRequests} pending request${account.pendingRequests > 1 ? 's' : ''}`;
                badge.style.background = 'rgba(27, 188, 157, 0.2)';
                badge.style.color = 'var(--primary)';
                badge.style.padding = '3px 8px';
                badge.style.borderRadius = '4px';
                badge.style.marginLeft = '8px';
                badge.style.fontSize = '12px';
                card.querySelector(".account-details").appendChild(badge);
            }
        } else {
            card.querySelector(".owner-badge").style.display = "none";
        }
        
        const viewBtn = card.querySelector(".view-account-btn");
        viewBtn.textContent = "Manage Account";
        viewBtn.addEventListener("click", () => {
            viewSharedAccount(account.id);
        });
        
        container.appendChild(card);
    });
}

function updateRecentActivity(transactions) {
    const activityList = document.getElementById('recent-activity-list');
    if (!activityList) return;
    
    if (!transactions || transactions.length === 0) {
        activityList.innerHTML = '<div class="no-activity">No recent activity</div>';
        return;
    }
    
    const recentTransactions = transactions.slice(0, 5);
    
    activityList.innerHTML = '';
    
    recentTransactions.forEach(tx => {
        const activityItem = document.createElement('div');
        activityItem.className = 'activity-item';
        
        let iconClass = 'deposit';
        let iconSymbol = 'fa-arrow-down';
        let activityText = 'Deposit';
        let amountClass = 'positive';
        let amountPrefix = '+';
        
        const txType = String(tx.type || '').toLowerCase();
        
        if (txType.includes('withdraw')) {
            iconClass = 'withdraw';
            iconSymbol = 'fa-arrow-up';
            activityText = 'Withdraw';
            amountClass = 'negative';
            amountPrefix = '-';
        } else if (txType.includes('transfer')) {
            iconClass = 'transfer';
            iconSymbol = 'fa-paper-plane';
            activityText = 'Transfer';
            amountClass = 'negative';
            amountPrefix = '-';
        }
        
        const timeAgo = getTimeAgo(tx.timestamp);
        
        activityItem.innerHTML = `
            <div class="activity-icon ${iconClass}">
                <i class="fas ${iconSymbol}"></i>
            </div>
            <div class="activity-content">
                <div class="activity-text">${activityText}</div>
                <div class="activity-time">${timeAgo}</div>
            </div>
            <div class="activity-amount ${amountClass}">
                ${amountPrefix}$${Math.abs(tx.amount).toLocaleString()}
            </div>
        `;
        
        activityList.appendChild(activityItem);
    });
}

function getTimeAgo(timestamp) {
    try {
        const now = new Date();
        const past = new Date(timestamp);
        const diffMs = now - past;
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMs / 3600000);
        const diffDays = Math.floor(diffMs / 86400000);
        
        if (diffMins < 1) return 'Just now';
        if (diffMins < 60) return `${diffMins}m ago`;
        if (diffHours < 24) return `${diffHours}h ago`;
        if (diffDays < 7) return `${diffDays}d ago`;
        return past.toLocaleDateString();
    } catch (e) {
        return 'Recently';
    }
}

function viewSharedAccount(accountId) {
    currentSharedAccountId = accountId;
   
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            action: "getSharedAccountDetails",
            data: { accountId }
        })
    })
    .then(response => response.json())
    .then(account => {
        if (!account) return;
       
        document.getElementById("shared-account-name").textContent = account.name;
        document.getElementById("shared-account-balance").textContent = account.balance.toLocaleString();
        document.getElementById("shared-account-code").textContent = account.code;
        
        document.getElementById("shared-accounts-list-view").style.display = "none";
        document.getElementById("shared-account-detail-view").style.display = "block";
        
        // Initialize shared account buttons
        const depositBtn = document.getElementById("shared-deposit-btn");
        const withdrawBtn = document.getElementById("shared-withdraw-btn");
        const transferBtn = document.getElementById("shared-transfer-btn");
        
        if (depositBtn) depositBtn.onclick = depositToSharedAccount;
        if (withdrawBtn) withdrawBtn.onclick = withdrawFromSharedAccount;
        if (transferBtn) transferBtn.onclick = transferFromSharedAccount;

        // Initialize tabs
        document.querySelectorAll(".shared-account-tab").forEach(tab => {
            tab.addEventListener("click", function() {
                const tabName = this.getAttribute("data-tab");
                
                if (tabName === "members") {
                    loadAccountMembers(currentSharedAccountId);
                    loadPendingRequests(currentSharedAccountId);
                }
                
                if (tabName === "settings") {
                    setTimeout(() => {
                        // Settings buttons
                        const renameBtn = document.getElementById("rename-account-btn");
                        const regenerateBtn = document.getElementById("regenerate-code-btn");
                        const leaveBtn = document.getElementById("leave-account-btn");
                        const deleteBtn = document.getElementById("delete-account-btn");
                        
                        // Update code display
                        const codeDisplay = document.getElementById("account-code-display");
                        if (codeDisplay) {
                            codeDisplay.textContent = account.code;
                        }
                        
                        // Set click handlers
                        if (renameBtn) {
                            renameBtn.onclick = function() {
                                console.log("Rename button clicked!");
                                renameSharedAccount();
                            };
                        }
                        
                        if (regenerateBtn) {
                            console.log("Setting regenerate button handler");
                            regenerateBtn.onclick = function() {
                                console.log("Regenerate button clicked!");
                                regenerateSharedAccountCode();
                            };
                        }
                        
                        if (leaveBtn) {
                            leaveBtn.onclick = function() {
                                console.log("Leave button clicked!");
                                leaveSharedAccount();
                            };
                        }
                        
                        if (deleteBtn) {
                            deleteBtn.onclick = function() {
                                console.log("Delete button clicked!");
                                deleteSharedAccount();
                            };
                        }
                        
                        // Show/hide owner actions
                        const ownerActions = document.getElementById("owner-only-actions");
                        if (ownerActions) {
                            ownerActions.style.display = account.isOwner ? "block" : "none";
                        }
                        
                        console.log("All settings buttons initialized");
                        
                        // Fix for Leave and Delete buttons
                        const leaveAccountBtn = document.getElementById("leave-account-btn");
                        const deleteAccountBtn = document.getElementById("delete-account-btn");

                        if (leaveAccountBtn) {
                            leaveAccountBtn.addEventListener("click", function(e) {
                                e.preventDefault();
                                console.log("Leave button clicked - event listener");
                                leaveSharedAccount();
                            });
                        }

                        if (deleteAccountBtn) {
                            deleteAccountBtn.addEventListener("click", function(e) {
                                e.preventDefault();
                                console.log("Delete button clicked - event listener");
                                deleteSharedAccount();
                            });
                        }
                    }, 100);
                }
            });
        });

        // Load transactions
        if (account.transactions) {
            renderTransactions(account.transactions);
        }
    });
}

function showSharedAccountsList() {
    document.getElementById("shared-account-detail-view").style.display = "none";
    document.getElementById("shared-accounts-list-view").style.display = "block";
    currentSharedAccountId = null;
    
    if (window.sharedAccountRefreshInterval) {
        clearInterval(window.sharedAccountRefreshInterval);
        window.sharedAccountRefreshInterval = null;
    }
}

function renderTransactions(transactions) {
    const container = document.querySelector("#shared-transactions-container .transactions-content");
    if (!container) return;
    
    container.innerHTML = "";
    
    if (!transactions || transactions.length === 0) {
        container.innerHTML = `<div class="no-transactions-message">No transactions yet</div>`;
        return;
    }
    
    const sortedTransactions = [...transactions].sort((a, b) => {
        return new Date(b.timestamp) - new Date(a.timestamp);
    });
    
    sortedTransactions.forEach(tx => {
        let txType = String(tx.type || "").toLowerCase();
        
        let typeName = "Unknown";
        let icon = "fa-exchange-alt";
        let typeClass = "unknown";
        
        if (!isNaN(txType)) {
            const numType = parseInt(txType);
            switch(numType) {
                case 1: txType = "deposit"; break;
                case 2: txType = "withdraw"; break;
                case 3: txType = "society_deposit"; break;
                case 4: txType = "society_withdraw"; break;
                case 5: txType = "transfer"; break;
                case 6: txType = "shared_deposit"; break;
                case 7: txType = "shared_withdraw"; break;
                case 8: txType = "shared_transfer"; break;
            }
        }
        
        if (txType.includes("deposit")) {
            icon = "fa-arrow-down";
            typeClass = "deposit";
            if (txType.includes("society")) {
                typeName = "Society Deposit";
            } else if (txType.includes("shared")) {
                typeName = "Shared Deposit";
            } else {
                typeName = "Deposit";
            }
        } else if (txType.includes("withdraw")) {
            icon = "fa-arrow-up";
            typeClass = "withdraw";
            if (txType.includes("society")) {
                typeName = "Society Withdraw";
            } else if (txType.includes("shared")) {
                typeName = "Shared Withdraw";
            } else {
                typeName = "Withdraw";
            }
        } else if (txType.includes("transfer")) {
            icon = "fa-paper-plane";
            typeClass = "transfer";
            if (txType.includes("shared")) {
                typeName = "Shared Transfer";
            } else {
                typeName = "Transfer";
            }
        } else if (txType.includes("unknown")) {
            const match = txType.match(/unknown_(\d+)/);
            if (match && match[1]) {
                const numType = parseInt(match[1]);
                switch(numType) {
                    case 1: typeName = "Deposit"; icon = "fa-arrow-down"; typeClass = "deposit"; break;
                    case 2: typeName = "Withdraw"; icon = "fa-arrow-up"; typeClass = "withdraw"; break;
                    case 3: typeName = "Society Deposit"; icon = "fa-arrow-down"; typeClass = "deposit"; break;
                    case 4: typeName = "Society Withdraw"; icon = "fa-arrow-up"; typeClass = "withdraw"; break;
                    case 5: typeName = "Transfer"; icon = "fa-paper-plane"; typeClass = "transfer"; break;
                    case 6: typeName = "Shared Deposit"; icon = "fa-arrow-down"; typeClass = "deposit"; break;
                    case 7: typeName = "Shared Withdraw"; icon = "fa-arrow-up"; typeClass = "withdraw"; break;
                    case 8: typeName = "Shared Transfer"; icon = "fa-paper-plane"; typeClass = "transfer"; break;
                    default: typeName = "Unknown " + numType;
                }
            }
        }
        
        const txElement = document.createElement("div");
        txElement.className = "transaction-item";
        txElement.innerHTML = `
            <div class="transaction-type ${typeClass}">
                <i class="fas ${icon}"></i>
                ${typeName}
            </div>
            <div class="transaction-amount ${tx.amount < 0 ? "negative" : ""}">
                ${tx.amount < 0 ? "-" : "+"}${Math.abs(tx.amount).toLocaleString()}
            </div>
            <div class="transaction-note">${tx.note || "-"}</div>
            <div class="transaction-date">${new Date(tx.timestamp).toLocaleString()}</div>
        `;
        
        container.appendChild(txElement);
    });
    
    const currentFilter = document.getElementById("transaction-type-filter");
    if (currentFilter && currentFilter.value !== "all") {
        const filter = currentFilter.value.toLowerCase();
        container.querySelectorAll(".transaction-item").forEach(item => {
            const type = item.querySelector(".transaction-type").textContent.toLowerCase();
            if (!type.includes(filter)) {
                item.style.display = "none";
            }
        });
    }
}

function loadAccountMembers(accountId) {
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
            action: "getSharedAccountMembers",
            data: { accountId }
        })
    })
    .then(response => response.json())
    .then(members => {
        renderMembers(members);
    });
}

function loadPendingRequests(accountId) {
    const requestsContainer = document.getElementById("pending-requests-container");
    if (requestsContainer) {
        requestsContainer.innerHTML = `<div class="loading-message">Loading requests...</div>`;
    }
    
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
            action: "getSharedAccountRequests",
            data: { 
                accountId: accountId,
                forceRefresh: true,
                timestamp: Date.now()
            }
        })
    })
    .then(response => response.json())
    .then(requests => {
        renderPendingRequests(requests);
    })
    .catch(error => {
        if (requestsContainer) {
            requestsContainer.innerHTML = `<div class="error-message">Error loading requests</div>`;
        }
    });
}

function renderMembers(members) {
    const container = document.getElementById("members-list-container");
    if (!container) return;
    
    container.innerHTML = "";
    
    if (!members || members.length === 0) {
        container.innerHTML = `<div class="no-members-message">No members found</div>`;
        return;
    }
    
    const template = document.getElementById("member-item-template");
    if (!template) return;
    
    members.forEach(member => {
        const memberElement = template.content.cloneNode(true);
        
        memberElement.querySelector(".member-name").textContent = member.fullname;
        memberElement.querySelector(".member-role").textContent = member.permissionLevel > 1 ? "Manager" : "Member";
        memberElement.querySelector(".member-joined").textContent = `Joined: ${new Date(member.joinedAt).toLocaleDateString()}`;
        
        const account = sharedAccounts.find(acc => acc.id === currentSharedAccountId);
        const isCurrentUserOwner = account && account.isOwner;
        
        const changeRoleBtn = memberElement.querySelector(".change-role-btn");
        const removeMemberBtn = memberElement.querySelector(".remove-member-btn");
        
        if (!isCurrentUserOwner) {
            changeRoleBtn.style.display = "none";
            removeMemberBtn.style.display = "none";
        }
        
        changeRoleBtn.addEventListener("click", () => {
            const newRole = member.permissionLevel > 1 ? 1 : 2;
            changeAccountMemberRole(currentSharedAccountId, member.id, newRole);
        });
        
        removeMemberBtn.addEventListener("click", () => {
            removeAccountMember(currentSharedAccountId, member.id);
        });
        
        container.appendChild(memberElement);
    });
}

function renderPendingRequests(requests) {
    const container = document.getElementById("pending-requests-container");
    if (!container) return;
    
    container.innerHTML = "";
    
    if (!requests || requests.length === 0) {
        container.innerHTML = `<div class="no-requests-message">No pending requests</div>`;
        return;
    }
    
    const template = document.getElementById("request-item-template");
    if (!template) return;
    
    requests.forEach(request => {
        const requestElement = template.content.cloneNode(true);
        const rootElement = requestElement.querySelector(".request-item") || 
                           requestElement.firstElementChild;
        
        if (rootElement) {
            rootElement.setAttribute("data-request-id", request.id);
        }
        
        requestElement.querySelector(".request-name").textContent = request.fullname;
        requestElement.querySelector(".request-date").textContent = `Requested: ${new Date(request.requestedAt).toLocaleDateString()}`;
        
        requestElement.querySelector(".approve-btn").addEventListener("click", () => {
            respondToJoinRequest(request.id, true);
        });
        
        requestElement.querySelector(".deny-btn").addEventListener("click", () => {
            respondToJoinRequest(request.id, false);
        });
        
        container.appendChild(requestElement);
    });
}

function loadAccountDetails(accountId) {
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
            action: "getSharedAccountDetails",
            data: { accountId }
        })
    })
    .then(response => response.json())
    .then(account => {
        if (!account) return;
        
        document.getElementById("shared-account-name").textContent = account.name;
        document.getElementById("shared-account-balance").textContent = account.balance.toLocaleString();
        document.getElementById("shared-account-code").textContent = account.code;
        document.getElementById("account-code-display").textContent = account.code;
        
        document.getElementById("owner-only-actions").style.display = account.isOwner ? "block" : "none";
        
        if (account.transactions && account.transactions.length > 0) {
            renderTransactions(account.transactions);
        }
    })
    .catch(error => {
    });
}

function createSharedAccount() {
    const nameInput = document.getElementById("new-account-name");
    if (!nameInput) return;
    
    const name = nameInput.value.trim();
    
    if (!name) {
        sendNativeNotification("Please enter an account name", "error");
        return;
    }
    
    if (buttonClickInProgress) {
        console.log("Create operation already in progress, ignoring...");
        return;
    }
    
    buttonClickInProgress = true;
    
    // Disable the create button
    const createBtn = document.getElementById("confirm-create-account");
    if (createBtn) {
        createBtn.disabled = true;
        createBtn.textContent = "Creating...";
    }
    
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
            action: "createSharedAccount",
            data: { name }
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            document.getElementById("create-account-modal").style.display = "none";
            nameInput.value = "";
            
            loadSharedAccounts();
            sendNativeNotification("Shared account created successfully", "success");
        } else {
            sendNativeNotification(result.data || "Failed to create account", "error");
        }
    })
    .catch(error => {
        console.error("Error creating account:", error);
        sendNativeNotification("Failed to create account", "error");
    })
    .finally(() => {
        buttonClickInProgress = false;
        // Re-enable create button
        if (createBtn) {
            createBtn.disabled = false;
            createBtn.textContent = "Create Account";
        }
    });
}

function joinSharedAccount() {
    const codeInput = document.getElementById("join-account-code");
    if (!codeInput) return;
    
    const code = codeInput.value.trim();
    
    if (!code || code.length < 3 || code.length > 5 || !/^\d+$/.test(code)) {
        sendNativeNotification("Please enter a valid code (3-5 digits)", "error");
        return;
    }
    
    if (buttonClickInProgress) {
        console.log("Join operation already in progress, ignoring...");
        return;
    }
    
    buttonClickInProgress = true;
    
    // Disable the join button
    const joinBtn = document.getElementById("confirm-join-account");
    if (joinBtn) {
        joinBtn.disabled = true;
        joinBtn.textContent = "Sending Request...";
    }
    
    document.getElementById("join-account-modal").style.display = "none";
    const originalValue = codeInput.value;
    codeInput.value = "";
    
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
            action: "joinSharedAccount",
            data: { code }
        })
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response failed');
        }
        return response.json();
    })
    .then(result => {
        if (result.success) {
            sendNativeNotification("Join request sent successfully", "success");
        } else {
            sendNativeNotification(result.message || "Failed to send join request", "error");
        }
    })
    .catch(error => {
        console.error("Error joining account:", error);
        sendNativeNotification("An error occurred while trying to join the account", "error");
    })
    .finally(() => {
        buttonClickInProgress = false;
        // Re-enable join button
        if (joinBtn) {
            joinBtn.disabled = false;
            joinBtn.textContent = "Request Access";
        }
    });
}

function refreshAllSharedAccounts() {
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
            action: "getSharedAccounts"
        })
    })
    .then(response => response.json())
    .then(accounts => {
        sharedAccounts = accounts;
        
        if (document.getElementById("shared-accounts-list-view").style.display !== "none") {
            renderSharedAccountsList();
        }
        
        if (currentSharedAccountId) {
            loadAccountDetails(currentSharedAccountId);
        }
        
        sendNativeNotification("Accounts data refreshed", "success");
    })
    .catch(error => {
    });
}

function respondToJoinRequest(requestId, approve) {
    const buttons = document.querySelectorAll(".request-actions button");
    buttons.forEach(btn => {
        btn.disabled = true;
        btn.style.opacity = "0.7";
    });
    
    const requestItem = document.querySelector(`.request-item[data-request-id="${requestId}"]`);
    if (requestItem) {
        const existingErrors = requestItem.querySelectorAll(".error-message");
        existingErrors.forEach(el => el.remove());
    }
    
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
            action: "directRespondToRequest",
            data: { 
                requestId: requestId,
                approve: approve
            }
        })
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response failed');
        }
        return response.json();
    })
    .then(result => {
        buttons.forEach(btn => {
            btn.disabled = false;
            btn.style.opacity = "1"; 
        });
        
        if (requestItem) {
            requestItem.remove();
            
            const container = document.getElementById("pending-requests-container");
            if (container && container.children.length === 0) {
                container.innerHTML = `<div class="no-requests-message">No pending requests</div>`;
            }
        }
        
        if (approve) {
            setTimeout(() => {
                loadAccountMembers(currentSharedAccountId);
            }, 500);
        }
        
        sendNativeNotification(
            approve ? "Request approved" : "Request denied",
            approve ? "success" : "error"
        );
    })
    .catch(error => {
        buttons.forEach(btn => {
            btn.disabled = false;
            btn.style.opacity = "1";
        });
        
        if (requestItem) {
            const errorEl = document.createElement("div");
            errorEl.className = "error-message";
            errorEl.textContent = "Failed to process request. Try again.";
            errorEl.style.color = "red";
            errorEl.style.fontSize = "12px";
            errorEl.style.marginTop = "5px";
            requestItem.appendChild(errorEl);
        }
    });
}

function changeAccountMemberRole(accountId, memberId, newRole) {
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
            action: "changeSharedAccountPermission",
            data: { 
                accountId,
                memberId,
                newPermission: newRole
            }
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            loadAccountMembers(accountId);
        } else {
            sendNativeNotification(result.message || "Failed to change member role", "error");
        }
    });
}

function removeAccountMember(accountId, memberId) {
    showConfirmation(
        "Remove Member",
        "Are you sure you want to remove this member from the account?",
        "Remove Member",
        true // isDestructive = true
    ).then(confirmed => {
        if (!confirmed) {
            console.log("Remove member action cancelled by user");
            return;
        }
        
        console.log("User confirmed member removal, proceeding...");
        
        fetch(`https://${resourceName}/action`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ 
                action: "removeSharedAccountMember",
                data: { 
                    accountId: accountId,
                    memberId: memberId
                }
            })
        })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(result => {
            console.log("Remove member result:", result);
            if (result.success) {
                sendNativeNotification("Member removed successfully", "success");
                loadAccountMembers(accountId);
            } else {
                sendNativeNotification(result.message || "Failed to remove member", "error");
            }
        })
        .catch(error => {
            console.error("Error removing member:", error);
            sendNativeNotification("Failed to remove member", "error");
        });
    }).catch(error => {
        console.error("Confirmation promise error:", error);
        sendNativeNotification("An error occurred", "error");
    });
}

function depositToSharedAccount() {
    const amountInput = document.getElementById("shared-deposit-amount");
    const noteInput = document.getElementById("shared-deposit-note");
    if (!amountInput || !noteInput) return;
    
    const amount = parseInt(amountInput.value.trim());
    const note = noteInput.value.trim();
    
    if (!amount || amount <= 0 || isNaN(amount)) {
        sendNativeNotification("Please enter a valid amount", "error");
        return;
    }
    
    console.log("Depositing to shared account:", currentSharedAccountId, "amount:", amount);
    
    sendMessage("depositToSharedAccount", { 
        accountId: currentSharedAccountId,
        amount: amount,
        note: note
    }).then(response => {
        if (response.ok) {
            amountInput.value = "";
            noteInput.value = "";
            
            // Refresh account details
            setTimeout(() => {
                sendMessage("getSharedAccountDetails", { accountId: currentSharedAccountId })
                .then(response => response.json())
                .then(account => {
                    if (account) {
                        document.getElementById("shared-account-balance").textContent = account.balance.toLocaleString();
                        if (account.transactions) {
                            renderTransactions(account.transactions);
                        }
                    }
                });
            }, 500);
        }
    });
}

function withdrawFromSharedAccount() {
    const amountInput = document.getElementById("shared-withdraw-amount");
    const noteInput = document.getElementById("shared-withdraw-note");
    if (!amountInput || !noteInput) return;
    
    const amount = parseInt(amountInput.value.trim());
    const note = noteInput.value.trim();
    
    if (!amount || amount <= 0 || isNaN(amount)) {
        sendNativeNotification("Please enter a valid amount", "error");
        return;
    }
    
    console.log("Withdrawing from shared account:", currentSharedAccountId, "amount:", amount);
    
    sendMessage("withdrawFromSharedAccount", { 
        accountId: currentSharedAccountId,
        amount: amount,
        note: note
    }).then(response => {
        if (response.ok) {
            amountInput.value = "";
            noteInput.value = "";
            
            // Refresh account details
            setTimeout(() => {
                sendMessage("getSharedAccountDetails", { accountId: currentSharedAccountId })
                .then(response => response.json())
                .then(account => {
                    if (account) {
                        document.getElementById("shared-account-balance").textContent = account.balance.toLocaleString();
                        if (account.transactions) {
                            renderTransactions(account.transactions);
                        }
                    }
                });
            }, 500);
        }
    });
}

function transferFromSharedAccount() {
    const targetInput = document.getElementById("shared-transfer-id");
    const amountInput = document.getElementById("shared-transfer-amount");
    const noteInput = document.getElementById("shared-transfer-note");
    if (!targetInput || !amountInput || !noteInput) return;
    
    const target = parseInt(targetInput.value.trim());
    const amount = parseInt(amountInput.value.trim());
    const note = noteInput.value.trim();
    
    if (!target || isNaN(target)) {
        sendNativeNotification("Please enter a valid player ID", "error");
        return;
    }
    
    if (!amount || amount <= 0 || isNaN(amount)) {
        sendNativeNotification("Please enter a valid amount", "error");
        return;
    }
    
    console.log("Transferring from shared account:", currentSharedAccountId, "to:", target, "amount:", amount);
    
    sendMessage("transferFromSharedAccount", { 
        accountId: currentSharedAccountId,
        target: target,
        amount: amount,
        note: note
    }).then(response => {
        if (response.ok) {
            targetInput.value = "";
            amountInput.value = "";
            noteInput.value = "";
        }
    });
}

function showPinModal() {
    console.log("showPinModal called, isATMPinMode:", isATMPinMode);
    
    const pinModal = document.getElementById("card-pin-modal");
    
    if (pinModal) {
        console.log("PIN modal found, showing it");
        
        pinModal.style.cssText = `
            display: block !important;
            position: fixed !important;
            z-index: 999999 !important;
            top: 0 !important;
            left: 0 !important;
            width: 100vw !important;
            height: 100vh !important;
            background-color: rgba(0, 0, 0, 0.8) !important;
            pointer-events: auto !important;
            visibility: visible !important;
            opacity: 1 !important;
        `;
        
        // Ensure modal is at the top of DOM
        document.body.appendChild(pinModal);
        
        currentPin = "";
        updatePinDots();
        updatePinConfirmButton();
        hidePinError();
        
        console.log("PIN modal displayed");
    } else {
        console.error("PIN modal element not found!");
    }
}

function hidePinModal() {
    const pinModal = document.getElementById("card-pin-modal");
    if (pinModal) {
        pinModal.style.display = "none";
        
        // Reset PIN input
        currentPin = "";
        updatePinDots();
        updatePinConfirmButton();
        hidePinError();
        
        // Reset modal state
        const wasATMMode = isATMPinMode;
        isChangingPin = false;
        isATMPinMode = false;
        isReplacementCard = false;
        
        console.log("PIN modal hidden, wasATMMode:", wasATMMode);
        
        // Only close NUI focus if this was ATM mode
        // For regular card requests, keep the bank open
        if (wasATMMode) {
            sendMessage("close");
        }
    }
}

// PIN Input Functions
function addPinDigit(digit) {
    if (currentPin.length < 4) {
        currentPin += digit;
        updatePinDots();
        updatePinConfirmButton();
        
        // Haptic feedback (if supported)
        if (navigator.vibrate) {
            navigator.vibrate(50);
        }
        
        console.log("PIN digit added, length:", currentPin.length);
    }
}

function clearLastPinDigit() {
    if (currentPin.length > 0) {
        currentPin = currentPin.slice(0, -1);
        updatePinDots();
        updatePinConfirmButton();
        
        console.log("PIN digit removed, length:", currentPin.length);
    }
}

function updatePinDots() {
    for (let i = 1; i <= 4; i++) {
        const dot = document.getElementById(`pin-dot-${i}`);
        if (dot) {
            if (i <= currentPin.length) {
                dot.classList.add("filled");
            } else {
                dot.classList.remove("filled");
            }
        }
    }
}

function updatePinConfirmButton() {
    const confirmBtn = document.getElementById("pin-confirm-btn");
    if (confirmBtn) {
        if (currentPin.length === 4 && isValidPin(currentPin)) {
            confirmBtn.disabled = false;
        } else {
            confirmBtn.disabled = true;
        }
    }
}

function isValidPin(pin) {
    if (pin.length !== 4) return false;
    
    // Check for sequential numbers (1234, 4321)
    const isSequential = /^(0123|1234|2345|3456|4567|5678|6789|9876|8765|7654|6543|5432|4321|3210)$/.test(pin);
    if (isSequential) return false;
    
    // Check for repeated digits (1111, 2222, etc.)
    const isRepeated = /^(\d)\1{3}$/.test(pin);
    if (isRepeated) return false;
    
    return true;
}

function showPinError(message) {
    const pinError = document.getElementById("pin-error");
    if (pinError) {
        pinError.querySelector("span").textContent = message;
        pinError.style.display = "flex";
        
        // Add shake animation
        pinError.classList.add("shake");
        setTimeout(() => {
            pinError.classList.remove("shake");
        }, 500);
        
        console.log("PIN error shown:", message);
    }
}

function hidePinError() {
    const pinError = document.getElementById("pin-error");
    if (pinError) {
        pinError.style.display = "none";
    }
}

function confirmPin() {
    if (currentPin.length !== 4) {
        showPinError("PIN must be 4 digits");
        return;
    }
    
    if (!isValidPin(currentPin)) {
        showPinError("PIN cannot contain repeated sequences (like 1111 or 1234)");
        return;
    }
    
    hidePinError();
    
    console.log("PIN confirmed, mode:", { isATMPinMode, isChangingPin, isReplacementCard });
    
    if (isATMPinMode) {
        // ATM PIN verification - don't hide modal yet
        console.log("Sending ATM PIN verification request");
        sendMessage("verifyATMPin", { pin: currentPin });
    } else if (isChangingPin) {
        // Change existing PIN - keep bank open
        const feeElement = document.getElementById("card-fee");
        const fee = feeElement ? parseInt(feeElement.textContent) : 25;
        sendMessage("changeCardPin", { pin: currentPin, fee: fee });
        hidePinModal();
        // Bank stays open
    } else if (isReplacementCard) {
        // Request replacement card - keep bank open
        const feeElement = document.getElementById("card-fee");
        const fee = feeElement ? parseInt(feeElement.textContent) : 50;
        sendMessage("requestReplacementCard", { pin: currentPin, fee: fee });
        hidePinModal();
        // Bank stays open
    } else {
        // Request new physical card - keep bank open
        const feeElement = document.getElementById("card-fee");
        const fee = feeElement ? parseInt(feeElement.textContent) : 50;
        sendMessage("requestPhysicalCard", { pin: currentPin, fee: fee });
        hidePinModal();
        // Bank stays open
    }
}

// Card Button Management Functions
function updateCardButtons(cardStatus) {
    const requestCardBtn = document.getElementById("request-physical-card");
    const changePinBtn = document.getElementById("change-card-pin");
    
    if (!requestCardBtn || !changePinBtn) {
        console.error("Card button elements not found");
        return;
    }
    
    console.log("Updating card buttons with status:", cardStatus);
    
    if (!cardStatus) {
        // No card status data - show default state
        requestCardBtn.style.display = "inline-flex";
        changePinBtn.style.display = "none";
        return;
    }
    
    if (cardStatus.hasCardInDB) {
        // Player has a card in database
        if (cardStatus.hasCardInInventory) {
            // Has card in inventory - show change PIN option
            requestCardBtn.style.display = "none";
            changePinBtn.style.display = "inline-flex";
            changePinBtn.innerHTML = '<i class="fas fa-key"></i> Change PIN';
            changePinBtn.onclick = function() {
                changeCardPin();
            };
        } else {
            // Has card in DB but not in inventory - show replacement option
            requestCardBtn.style.display = "inline-flex";
            requestCardBtn.innerHTML = '<i class="fas fa-credit-card"></i> Request Replacement Card';
            requestCardBtn.onclick = function() {
                requestReplacementCard();
            };
            
            changePinBtn.style.display = "inline-flex";
            changePinBtn.innerHTML = '<i class="fas fa-key"></i> Change PIN';
            changePinBtn.onclick = function() {
                changeCardPin();
            };
        }
    } else {
        // No card in database - show request new card option
        requestCardBtn.style.display = "inline-flex";
        requestCardBtn.innerHTML = '<i class="fas fa-credit-card"></i> Request Physical Card';
        requestCardBtn.onclick = function() {
            requestPhysicalCard();
        };
        
        changePinBtn.style.display = "none";
    }
}

// Card Action Functions
function requestPhysicalCard() {
    isChangingPin = false;
    isReplacementCard = false;
    isATMPinMode = false;
    
    // Update modal content
    document.getElementById("pin-modal-title").textContent = "Set Your Card PIN";
    document.getElementById("pin-modal-description").textContent = "Choose a secure 4-digit PIN for your physical bank card";
    
    // Show fee
    const pinFeeElement = document.querySelector(".pin-fee");
    const cardFeeElement = document.getElementById("card-fee");
    if (pinFeeElement && cardFeeElement) {
        pinFeeElement.style.display = "block";
        cardFeeElement.textContent = "50"; // Default fee
    }
    
    showPinModal();
    console.log("Request physical card modal opened");
}

function requestReplacementCard() {
    isChangingPin = false;
    isReplacementCard = true;
    isATMPinMode = false;
    
    // Update modal content
    document.getElementById("pin-modal-title").textContent = "Set New PIN";
    document.getElementById("pin-modal-description").textContent = "Choose a secure 4-digit PIN for your replacement bank card";
    
    // Show fee
    const pinFeeElement = document.querySelector(".pin-fee");
    const cardFeeElement = document.getElementById("card-fee");
    if (pinFeeElement && cardFeeElement) {
        pinFeeElement.style.display = "block";
        cardFeeElement.textContent = "50"; // Replacement fee
    }
    
    showPinModal();
    console.log("Request replacement card modal opened");
}

function changeCardPin() {
    isChangingPin = true;
    isReplacementCard = false;
    isATMPinMode = false;
    
    // Update modal content
    document.getElementById("pin-modal-title").textContent = "Change Your PIN";
    document.getElementById("pin-modal-description").textContent = "Enter a new 4-digit PIN for your bank card";
    
    // Show fee
    const pinFeeElement = document.querySelector(".pin-fee");
    const cardFeeElement = document.getElementById("card-fee");
    if (pinFeeElement && cardFeeElement) {
        pinFeeElement.style.display = "block";
        cardFeeElement.textContent = "25"; // PIN change fee
    }
    
    showPinModal();
    console.log("Change PIN modal opened");
}

function renameSharedAccount() {
    const nameInput = document.getElementById("rename-account-input");
    if (!nameInput) return;
    
    const newName = nameInput.value.trim();
    
    if (!newName) {
        sendNativeNotification("Please enter a new account name", "error");
        return;
    }
    
    fetch(`https://${resourceName}/action`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
            action: "renameSharedAccount",
            data: { 
                accountId: currentSharedAccountId,
                newName
            }
        })
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            // עדכן את השם בכל מקום
            document.getElementById("shared-account-name").textContent = newName;
            
            nameInput.value = "";
            
            // עדכן ברשימה הראשית
            const account = sharedAccounts.find(acc => acc.id === currentSharedAccountId);
            if (account) {
                account.name = newName;
            }
            
            sendNativeNotification("Account renamed successfully", "success");
        }
    });
}

function regenerateSharedAccountCode() {
    console.log("regenerateSharedAccountCode called!"); // הוסף את זה
    if (!currentSharedAccountId) {
        sendNativeNotification("No shared account selected", "error");
        return;
    }
    
    showConfirmation(
        "Generate New Code",
        "Are you sure you want to generate a new access code? The old code will stop working immediately.",
        "Generate New Code",
        false
    ).then(confirmed => {
        if (!confirmed) return;
        
        fetch(`https://${resourceName}/action`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ 
                action: "regenerateSharedAccountCode",
                data: { accountId: currentSharedAccountId }
            })
        })
        .then(response => response.json())
        .then(result => {
            if (result.success) {
                sendNativeNotification("New access code generated successfully", "success");
                // רענן את פרטי החשבון כדי לקבל את הקוד החדש
                loadAccountDetails(currentSharedAccountId);
            }
        });
    });
}

function leaveSharedAccount() {
    if (!currentSharedAccountId) {
        sendNativeNotification("No shared account selected", "error");
        return;
    }
    
    showConfirmation(
        "Leave Shared Account",
        "Are you sure you want to leave this account? You will need to be invited again to rejoin.",
        "Leave Account",
        true // isDestructive = true
    ).then(confirmed => {
        if (!confirmed) {
            console.log("Leave action cancelled by user");
            return;
        }
        
        console.log("User confirmed leaving, proceeding...");
        
        fetch(`https://${resourceName}/action`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ 
                action: "leaveSharedAccount",
                data: { accountId: currentSharedAccountId }
            })
        })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(result => {
            console.log("Leave result:", result);
            sendNativeNotification("You have left the shared account", "success");
            
            // Remove from local cache
            const accountIndex = sharedAccounts.findIndex(acc => acc.id === currentSharedAccountId);
            if (accountIndex !== -1) {
                sharedAccounts.splice(accountIndex, 1);
            }
            
            // Navigate back and refresh
            showSharedAccountsList();
            loadSharedAccounts();
        })
        .catch(error => {
            console.error("Error leaving account:", error);
            sendNativeNotification("Failed to leave shared account", "error");
        });
    }).catch(error => {
        console.error("Confirmation promise error:", error);
        sendNativeNotification("An error occurred", "error");
    });
}

function deleteSharedAccount() {
    if (!currentSharedAccountId) {
        sendNativeNotification("No shared account selected", "error");
        return;
    }
    
    if (buttonClickInProgress) {
        console.log("Delete operation already in progress, ignoring...");
        return;
    }
    
    showConfirmation(
        "Delete Shared Account",
        "Are you sure you want to delete this account? This action cannot be undone, and all members will lose access.",
        "Delete Account",
        true
    ).then(confirmed => {
        if (!confirmed) {
            console.log("Delete action cancelled by user");
            return;
        }
        
        if (buttonClickInProgress) {
            console.log("Delete operation already in progress, ignoring duplicate...");
            return;
        }
        
        buttonClickInProgress = true;
        console.log("User confirmed deletion, proceeding...");
        
        // Disable the delete button temporarily
        const deleteBtn = document.getElementById("delete-account-btn");
        if (deleteBtn) {
            deleteBtn.disabled = true;
            deleteBtn.textContent = "Deleting...";
        }
        
        fetch(`https://${resourceName}/action`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ 
                action: "deleteSharedAccount",
                data: { accountId: currentSharedAccountId }
            })
        })
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(result => {
            console.log("Delete result:", result);
            sendNativeNotification("Shared account deleted successfully", "success");
            
            // Remove from local cache
            const accountIndex = sharedAccounts.findIndex(acc => acc.id === currentSharedAccountId);
            if (accountIndex !== -1) {
                sharedAccounts.splice(accountIndex, 1);
            }
            
            // Navigate back and refresh
            showSharedAccountsList();
            loadSharedAccounts();
        })
        .catch(error => {
            console.error("Error deleting account:", error);
            sendNativeNotification("Failed to delete shared account", "error");
        })
        .finally(() => {
            buttonClickInProgress = false;
            // Re-enable delete button
            if (deleteBtn) {
                deleteBtn.disabled = false;
                deleteBtn.textContent = "Delete Account";
            }
        });
    }).catch(error => {
        console.error("Confirmation promise error:", error);
        sendNativeNotification("An error occurred", "error");
        buttonClickInProgress = false;
    });
}

window.addEventListener("message", function(event) {
    const action = event.data.action;
    const eventData = event.data.data;

    if (ACTIONS[action]) {
        ACTIONS[action](eventData);
    }
    if (event.data.action === "updateSharedAccountCode") {
        const codeDisplay = document.getElementById("account-code-display");
        const sharedCodeDisplay = document.getElementById("shared-account-code");
        
        if (codeDisplay) {
            codeDisplay.textContent = event.data.data.newCode;
        }
        if (sharedCodeDisplay) {
            sharedCodeDisplay.textContent = event.data.data.newCode;
        }
    }
});

window.addEventListener("beforeunload", function() {
    if (window.sharedAccountRefreshInterval) {
        clearInterval(window.sharedAccountRefreshInterval);
    }
});

document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
        // Check if PIN modal is open and visible
        const pinModal = document.getElementById("card-pin-modal");
        if (pinModal && pinModal.style.display === "block") {
            // Don't close on ESC when PIN modal is open, let user use X button instead
            event.preventDefault();
            event.stopPropagation();
            return;
        } else {
            closeUI();
        }
    }
});


document.addEventListener("DOMContentLoaded", function() {
    if (transferSlider && transferAmount) {
        transferSlider.addEventListener("input", function() {
            transferAmount.value = this.value;
        });
        
        transferAmount.addEventListener("input", function() {
            if (this.value > transferSlider.max) {
                this.value = transferSlider.max;
            }
            transferSlider.value = this.value;
        });
    }
});

function handleDeposit(amount) {
}

function handleWithdraw(amount) {
}
