<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Stripe Payment with Billing Address</title>
    <script src="https://js.stripe.com/v3/"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/paymentPage.css">
    <link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/checkoutGuest.css">
    
<%@ page import="java.io.FileInputStream, java.util.Properties" %>
<%
    String googleMapsApiKey = "";
    try {
        // Specify the path to your config file
        String configFilePath = "C:/config/config.properties";
        Properties properties = new Properties();
        FileInputStream fis = new FileInputStream(configFilePath);
        properties.load(fis);
        fis.close();
        googleMapsApiKey = properties.getProperty("GOOGLE_MAPS_API_KEY", "");
        
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<script>
    const GOOGLE_MAPS_API_KEY = "<%= googleMapsApiKey %>";
    if (GOOGLE_MAPS_API_KEY) {
        const mapsScript = document.createElement('script');
        mapsScript.src = "https://maps.googleapis.com/maps/api/js?key=" + GOOGLE_MAPS_API_KEY + "&libraries=places&callback=initAutocomplete";
        mapsScript.async = true;
        mapsScript.defer = true;
        document.head.appendChild(mapsScript);
        console.log("Google Maps API Script Loaded:", mapsScript.src);
    } else {
        console.error("Google Maps API Key is missing!");
    }
</script>

    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        input {
            display: block;
            width: calc(100% - 20px);
            margin: 10px 0;
            padding: 10px;
            font-size: 16px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }

        input:focus {
            border-color: #6772e5;
            outline: none;
            box-shadow: 0 0 5px rgba(103, 114, 229, 0.5);
        }

        #card-element {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            margin-bottom: 20px;
        }

@media (max-width: 768px) {
#special-notes p {
    color: red;
    margin-left: -230px;
}
.delete-note-icon {
    font-size: 10px;
    color: red; 
    cursor: pointer;
	margin-right:-380px;
	margin-top:-15px;
    transition: color 0.3s, transform 0.3s;
}


}

    </style>
</head>
<%@ include file="/jsp/PaymantNavigation.jsp" %>

<body>
<%
    // Check if the user is logged in
    String userName = (String) session.getAttribute("userFirstName");
    boolean isLoggedIn = (userName != null);

    // If the user is not logged in, set the redirect target to this page
    if (!isLoggedIn) {
        String currentURL = request.getRequestURL().toString();
        session.setAttribute("redirectAfterLogin", currentURL);
    }
%>

<div class="checkout-container">
    <!-- Restaurant Info Section -->
    <div class="restaurant-info">
        <h1>ND Bengali Food</h1>
        <p>5504 Cinderlane Pkwy, Orlando, FL-32808</p>
        <p>Phone: 808-807-2025</p>
    </div>
<!-- Special Notes Section -->
    <div id="special-notes">
        <h2>Special Notes</h2>
        <!-- Special notes will be dynamically added here -->
    </div>
    <!-- Order Method Details Section -->
    <div id="order-method-details">
        <div class="details-row">
            <i class="fas fa-shopping-bag icon order-icon"></i>
            <p>
                <strong>Order Method:</strong>
                <span class="delivery-or-pickup">N/A</span>
                <a href="#" class="edit-link">Edit</a>
            </p>
        </div>
        <div class="details-row">
            <i class="fas fa-calendar-alt icon"></i>
            <p><strong>Date:</strong> <span class="date">N/A</span></p>
        </div>
        <div class="details-row">
            <i class="fas fa-clock icon"></i>
            <p><strong>Time:</strong> <span class="time">N/A</span></p>
        </div>
        <div class="details-row">
            <i class="fas fa-map-marker-alt icon"></i>
            <p><strong>Address:</strong> <span class="address">N/A</span></p>
        </div>
    </div>

    <!-- Order Summary Section -->
    <div id="order-summary-details">
        <div class="order-header">
            <h2>Your Orders (<span id="total-items">0</span>)</h2>
            <span id="toggle-icon" class="toggle-icon">
                <i class="fas fa-chevron-down"></i>
            </span>
        </div>
        <div class="summary-row always-visible" id="first-item-row"></div>
        <div id="orders-lists" class="hidden"></div>
        <div class="summary-row">
            <span>Estimated sales tax (7%)</span>
            <span>$<span id="tax">0.00</span></span>
        </div>
        <div class="total-rows">
            <span>Total (Including Tax)</span>
            <span>$<span id="subtotal">0.00</span></span>
        </div>
    </div>

    <% if (!isLoggedIn) { %>
    <div id="checkout-Account-link">
        <div class="checkout-Account">
            <a href="<%= request.getContextPath() %>/jsp/SignIn.jsp" class="checkout-btn">Have an Account? Log In</a>
        </div>
        <div class="checkout-guest">
            <a href="<%= request.getContextPath() %>/jsp/CheckoutGuest.jsp" class="checkout-btn">Checkout as a Guest</a>
        </div>
    </div>
    <% } else { %>
    
   <form id="payment-form" method="POST">
    <input type="hidden" name="amount" id="amount" value="">
    
    <h2>Choose Payment, <%= userName %></h2>

    <!-- Payment Method Options -->
    <div class="payment-switch">
        <button type="button" id="creditCardBtn" class="switch-btn active">Credit Card</button>
        <button type="button" id="applePayBtn" class="switch-btn">Apple Pay</button>
        <button type="button" id="googlePayBtn" class="switch-btn">Google Pay</button>
    </div>

    <!-- Credit Card Payment -->
    <div id="creditCardForm" class="payment-section">
        <h3>Credit Card Payment</h3>
        <div id="card-container"></div>
        <div id="card-element"><!-- Stripe.js injects the Card Element here --></div>

<div class="form-group">
        <label for="billingFullName">Full Name</label>
        <input type="text" id="billingFullName" name="billing_name" placeholder="Full Name" required>
  </div>
       <div class="form-group">
    <label for="biAutoAdderss">Address</label>
    <input type="text" id="biAutoAdderss" name="bi_auto_Adderss"placeholder="Start typing your address" required>
</div>

<div class="form-group">
    <label for="biAptName">Address Line 1 (Optional)</label>
    <input type="text" id="biAptName" name="bi_apt_name" placeholder="Apt, Unit, etc.">
</div>

<div class="form-group">
    <label for="billingCity">City</label>
    <input type="text" id="billingCity" name="billing_address_city" placeholder="City" required>
</div>

<div class="form-group">
    <label for="billingState">State</label>
    <input type="text" id="billingState" name="billing_address_state" placeholder="State" required>
</div>

<div class="form-group">
    <label for="billingZipCode">ZIP Code</label>
    <input type="text" id="billingZipCode" name="billing_address_zip" placeholder="ZIP Code" required>
</div>


    </div>

    <!-- Apple Pay Payment -->
    <div id="applePayForm" class="payment-section hidden">
        <h3>Apple Pay</h3>
        <p>Click below to pay using Apple Pay.</p>
    </div>

    <!-- Google Pay Payment -->
    <div id="googlePayForm" class="payment-section hidden">
        <h3>Google Pay</h3>
        <p>Click below to pay using Google Pay.</p>
    </div>

    <!-- Tip Section -->
    <div class="tip-container">
        <h6><i class="fas fa-hand-holding-usd tip-icon"></i> Add a Tip</h6>
        <div class="tip-options">
            <div class="tip-option" data-percent="18">18%<br>$<span class="amount">0.00</span></div>
            <div class="tip-option" data-percent="22">22%<br>$<span class="amount">0.00</span></div>
            <div class="tip-option" data-percent="25">25%<br>$<span class="amount">0.00</span></div>
            <div class="tip-option other">
                Other<br>
                <input type="number" id="customTip" placeholder="Enter Tip Amount" class="hidden">
            </div>
        </div>
    </div>

    <!-- Total Section -->
    <div class="s-total-row">
        <span>Total (Including Tax)</span>
        <span>$<span id="s-totall">0.00</span></span>
    </div>

    <!-- Payment Buttons -->
    <div class="payment-buttons">
    <button id="card-button" class="payment-btn hidden">Pay with Credit Card</button>
    <button id="apple-pay-button" class="payment-btn hidden">Pay with Apple Pay</button>
    <button id="google-pay-button" class="payment-btn hidden">Pay with Google Pay</button>
    </div>


<div id="error-modal" class="modal">
    <div class="modal-content">
        <span class="close-btn">&times;</span>
        <p class="modal-body"></p>
    </div>
</div>



</form>

    <% } %>
</div>
<%@ include file="/jsp/footer.jsp" %>
</body>
    <script>
    
    const TAX_RATE = 0.07;
    let items = [];
    let totalQuantity = 0;
    
    document.addEventListener("DOMContentLoaded", function () {
    	    loadOrderDetails();
    	    renderOrderList();
    	    initToggleFeature();
    	    setupPaymentMethodSwitch();
    	   
       
    });
    
    function loadOrderDetails() {
        const orderMethod = localStorage.getItem('orderMethod') || 'Pickup';
        const orderDate = localStorage.getItem('orderDate') || 'N/A';
        const orderTime = localStorage.getItem('orderTime') || 'N/A';
        const orderAddress = localStorage.getItem('orderAddress') || 'N/A';

        document.querySelector('.delivery-or-pickup').textContent = orderMethod;
        document.querySelector('.date').textContent = orderDate;
        document.querySelector('.time').textContent = orderTime;
        document.querySelector('.address').textContent = orderAddress;

        // Dynamically update icon based on order method
        const orderIcon = document.querySelector('.order-icon');
        if (orderMethod === 'Delivery') {
            orderIcon.className = 'fas fa-truck icon order-icon'; // Change to delivery icon
        } else {
            orderIcon.className = 'fas fa-shopping-bag icon order-icon'; // Default to pickup icon
        }

        const savedItems = localStorage.getItem('cartItems');
        items = savedItems ? JSON.parse(savedItems) : [];
        console.log('Loaded Items:', items);

        // Retrieve delivery fee
        const deliveryFee = parseFloat(localStorage.getItem('deliveryFee')) || 0;
        console.log('Retrieved Delivery Fee:', deliveryFee);
        return deliveryFee; // Return delivery fee for later use
    }
    
    function renderOrderList() {
        const firstItemRow = document.getElementById("first-item-row");
        const orderList = document.getElementById("orders-lists");
        const cartCountElement = document.getElementById("total-items");
        const subtotalElement = document.getElementById("subtotal");
        const taxElement = document.getElementById("tax"); // Targeting the tax display element
        const sTotalElement = document.getElementById("s-totall");

        const deliveryFee = loadOrderDetails() || 0; // Default delivery fee to 0
        let totalQuantity = 0; // Initialize total quantity
        let subtotal = 0; // Initialize subtotal
        let totalTax = 0; // Initialize total tax

        // Clear existing content
        orderList.innerHTML = "";
        firstItemRow.innerHTML = "";

        // Handle empty cart
        if (!items || items.length === 0) {
            firstItemRow.innerHTML = "<p>Your cart is empty</p>";
            subtotalElement.textContent = "0.00";
            taxElement.textContent = "0.00"; // Clear tax
            sTotalElement.textContent = "0.00";
            cartCountElement.textContent = "0";
            return;
        }

        // Loop through items and calculate row-wise subtotal, tax, and total quantity
        items.forEach((item, index) => {
            const itemTotal = item.itemPrice * item.quantity; // Total price for this item
            const tax = itemTotal * TAX_RATE; // Tax for this item
            subtotal += itemTotal; // Accumulate subtotal
            totalTax += tax; // Accumulate total tax
            totalQuantity += item.quantity; // Accumulate total quantity

            // Generate HTML for each item
            const itemHTML = `
                <div class="item-details">
                    <span>Item:  ` + item.itemName + `</span> x <span>` + item.quantity + `</span>
                </div>
                <div class="item-price">
                    <span>$` + itemTotal + `</span>
                </div>

            `;

            if (index === 0) {
                firstItemRow.innerHTML = itemHTML;
            } else {
                const itemElement = document.createElement("div");
                itemElement.classList.add("summary-row");
                itemElement.innerHTML = itemHTML;
                orderList.appendChild(itemElement);
            }
        });

        // Calculate total with tax and delivery fee
        const totalWithTax = subtotal + totalTax + deliveryFee;

     // Update the DOM with calculated values
        subtotalElement.textContent = (subtotal + totalTax).toFixed(2); // Tax + total item price
        taxElement.textContent = totalTax.toFixed(2); // Display total tax
        sTotalElement.textContent = (subtotal + totalTax + deliveryFee).toFixed(2); // Subtotal + Delivery Fee
        cartCountElement.textContent = totalQuantity; // Display total item count
    }

    function initToggleFeature() {
        const toggleIcon = document.getElementById("toggle-icon");
        const orderList = document.getElementById("orders-lists");

        toggleIcon.addEventListener("click", () => {
            const isHidden = orderList.classList.toggle("hidden");
            const icon = toggleIcon.querySelector("i");
            icon.className = isHidden ? "fas fa-chevron-down" : "fas fa-chevron-up";
        });
    }

    function updateSummary(tax, totalWithTax) {
        document.getElementById("tax").innerText = tax;
        document.getElementById("subtotal").innerText = totalWithTax;
        
    }
    
    
    document.querySelector('.edit-link').addEventListener('click', (e) => {  
        e.preventDefault();
        window.location.href = '/bangalifood/jsp/menu.jsp'; // Adjust path as needed.
    });

    
    document.addEventListener("DOMContentLoaded", function () {
        const cartItems = JSON.parse(localStorage.getItem('cartItems')) || [];
        const specialNotesContainer = document.getElementById('special-notes');

        // Clear the container initially
        specialNotesContainer.innerHTML = "";

        // Loop through cart items and add special notes
        cartItems.forEach((item, index) => {
            if (item.specialNote && item.specialNote.trim() !== "") {
                const specialNote = item.specialNote;

                // Create a new div for each special note
                const noteDiv = document.createElement('div');
                noteDiv.className = 'note-item';

                // Add the special note and delete icon using string concatenation
                noteDiv.innerHTML = 
                    '<p><strong>Special Note:</strong> ' + specialNote + '</p>' +
                    '<i class="fas fa-trash-alt delete-note-icon" data-index="' + index + '"></i>';

                // Append the note to the container
                specialNotesContainer.appendChild(noteDiv);
            }
        });

        // Add event listener for delete icons (event delegation)
        specialNotesContainer.addEventListener('click', function (e) {
            if (e.target && e.target.classList.contains('delete-note-icon')) {
                const index = e.target.getAttribute('data-index');
                deleteSpecialNote(index, cartItems, e.target.closest('.note-item'));
            }
        });
    });

    function deleteSpecialNote(index, cartItems, noteDiv) {
        // Remove the specialNote property from the item
        delete cartItems[index].specialNote;

        // Update localStorage
        localStorage.setItem('cartItems', JSON.stringify(cartItems));

        // Remove the note div from the DOM
        noteDiv.remove();
    }

       

  //Setup tipping functionality


    document.addEventListener("DOMContentLoaded", function () {
        const subtotalElement = document.getElementById('subtotal'); // Original total
        const sTotalElement = document.getElementById('s-totall'); // Total including tip
        const tipOptions = document.querySelectorAll('.tip-option'); // Tip options
        const customTipInput = document.getElementById('customTip'); // Custom tip input field

        // Store the original subtotal
        let originalSubtotal = parseFloat(subtotalElement.textContent) || 0;

        // Function to display calculated tip amounts for percentage-based tips
        function displayTipAmount() {
            tipOptions.forEach(option => {
                const percent = option.getAttribute('data-percent');
                if (percent) {
                    const calculatedTip = (originalSubtotal * parseInt(percent) / 100).toFixed(2);
                    option.querySelector('.amount').textContent = calculatedTip;
                }
            });
        }

        // Function to update the total including tip
        function updateTotal(tipAmount = 0) {
            const totalIncludingTip = (originalSubtotal + parseFloat(tipAmount)).toFixed(2); // Add tip to subtotal
            sTotalElement.textContent = totalIncludingTip; // Update total on UI
        }

        // Handle tip option selection
        function selectTip(element) {
            // Reset all options and hide custom tip input
            tipOptions.forEach(option => option.classList.remove('selected'));
            customTipInput.classList.add('hidden');

            // Highlight the selected tip option
            element.classList.add('selected');

            // Calculate the tip amount and update total
            const tipPercent = parseInt(element.getAttribute('data-percent'), 10);
            const tipAmount = (originalSubtotal * tipPercent) / 100;
            updateTotal(tipAmount);
        }

        // Show custom tip input
        function showCustomTipInput() {
            // Reset all options and show the custom tip input
            tipOptions.forEach(option => option.classList.remove('selected'));
            customTipInput.classList.remove('hidden');
            customTipInput.value = ''; // Reset input
            customTipInput.focus(); // Focus on the input
        }

        // Handle custom tip input changes
        customTipInput.addEventListener('input', function () {
            const customTipAmount = parseFloat(this.value) || 0; // Get custom tip amount
            updateTotal(customTipAmount); // Update total with custom tip
        });

        // Default value for custom tip input when blurred
        customTipInput.addEventListener('blur', function () {
            if (!this.value.trim()) {
                this.value = '0.00'; // Set to 0.00 if left empty
                updateTotal(0);
            }
        });

        // Add click event listeners to tip options
        tipOptions.forEach(option => {
            if (!option.classList.contains('other')) {
                option.addEventListener('click', function () {
                    selectTip(this);
                });
            } else {
                option.addEventListener('click', showCustomTipInput);
            }
        });

        // Display initial tip amounts and set default total
        displayTipAmount();
        updateTotal();
    });
  

    document.addEventListener("DOMContentLoaded", function () {
        const creditCardForm = document.getElementById("creditCardForm");
        const cardButton = document.getElementById("card-button");
        const switchButtons = document.querySelectorAll(".switch-btn");

        // Set Credit Card as the default visible payment option
        creditCardForm.classList.remove("hidden");
        cardButton.classList.remove("hidden");
        document.getElementById("creditCardBtn").classList.add("active");

        // Ensure other buttons are hidden
        document.getElementById("applePayForm").classList.add("hidden");
        document.getElementById("apple-pay-button").classList.add("hidden");
        document.getElementById("googlePayForm").classList.add("hidden");
        document.getElementById("google-pay-button").classList.add("hidden");

        // Initialize the switch button functionality
        setupPaymentMethodSwitch();
    });
    
    function setupPaymentMethodSwitch() {
        const creditCardForm = document.getElementById("creditCardForm");
        const applePayForm = document.getElementById("applePayForm");
        const googlePayForm = document.getElementById("googlePayForm");

        const cardButton = document.getElementById("card-button");
        const applePayButton = document.getElementById("apple-pay-button");
        const googlePayButton = document.getElementById("google-pay-button");

        const switchButtons = document.querySelectorAll(".switch-btn");

        switchButtons.forEach((button) => {
            button.addEventListener("click", function (e) {
                e.preventDefault();

                // Hide all payment sections and buttons
                creditCardForm.classList.add("hidden");
                applePayForm.classList.add("hidden");
                googlePayForm.classList.add("hidden");

                cardButton.classList.add("hidden");
                applePayButton.classList.add("hidden");
                googlePayButton.classList.add("hidden");

                // Highlight selected payment method
                switchButtons.forEach((btn) => btn.classList.remove("active"));
                this.classList.add("active");

                // Show the selected form and corresponding button
                if (this.id === "creditCardBtn") {
                    creditCardForm.classList.remove("hidden");
                    cardButton.classList.remove("hidden");
                } else if (this.id === "applePayBtn") {
                    applePayForm.classList.remove("hidden");
                    applePayButton.classList.remove("hidden");
                } else if (this.id === "googlePayBtn") {
                    googlePayForm.classList.remove("hidden");
                    googlePayButton.classList.remove("hidden");
                }
            });
        });
    }
   
   
    let autocomplete;

    function initAutocomplete() {
        // Initialize Google Places Autocomplete
        autocomplete = new google.maps.places.Autocomplete(
            document.getElementById("biAutoAdderss"),
            { types: ["address"], componentRestrictions: { country: "us" } } // Restrict results to addresses in the US
        );

        // Event listener for when a place is selected
        autocomplete.addListener("place_changed", () => {
            const place = autocomplete.getPlace();

            // Initialize variables to hold address components
            let streetNumber = "";
            let route = "";
            let subpremise = "";
            let city = "";
            let state = "";
            let zip = "";

            // Parse address components
            if (place.address_components) {
                place.address_components.forEach((component) => {
                    const types = component.types;

                    if (types.includes("street_number")) {
                        streetNumber = component.long_name; // Street Number
                    }
                    if (types.includes("route")) {
                        route = component.long_name; // Street Name
                    }
                    if (types.includes("subpremise")) {
                        subpremise = component.long_name; // Apartment, Unit, etc.
                    }
                    if (types.includes("locality")) {
                        city = component.long_name; // City
                    }
                    if (types.includes("administrative_area_level_1")) {
                        state = component.short_name; // State
                    }
                    if (types.includes("postal_code")) {
                        zip = component.long_name; // ZIP Code
                    }
                });
            }

            // Combine street number and route for the main address
            const mainAddress = [streetNumber, route].filter(Boolean).join(" ").trim();

            // Populate the form fields
            document.getElementById("biAutoAdderss").value = mainAddress; // Address field
            document.getElementById("billingCity").value = city; // City
            document.getElementById("billingState").value = state; // State
            document.getElementById("billingZipCode").value = zip; // ZIP Code

            // Populate Address Line 1 (Optional) with subpremise if it exists
            if (subpremise) {
                document.getElementById("biAptName").value = subpremise; // Optional
            } else {
                document.getElementById("biAptName").value = ""; // Clear if empty
            }
        });
    }
    document.addEventListener("DOMContentLoaded", function () {
        const fullNameInput = document.getElementById("billingFullName");
        const fullNameErrorMessage = document.createElement("div");
        fullNameErrorMessage.style.color = "red";
        fullNameErrorMessage.style.fontSize = "12px";
        fullNameErrorMessage.style.marginTop = "5px";
        fullNameErrorMessage.id = "fullNameError";
        fullNameErrorMessage.textContent = ""; // Initially empty

        // Append the error message below the input field
        fullNameInput.parentNode.appendChild(fullNameErrorMessage);

        fullNameInput.addEventListener("input", function () {
            const value = fullNameInput.value;

            // Regular expression to allow only letters, spaces, and enforce at least two words
            const namePattern = /^[A-Za-z]{2,}(\s[A-Za-z]{2,})+$/;

            // Check if the input value matches the pattern
            if (namePattern.test(value)) {
                fullNameInput.style.borderColor = "green"; // Valid input style
                fullNameErrorMessage.textContent = ""; // Clear error message
            } else {
                fullNameInput.style.borderColor = "red"; // Invalid input style
                fullNameErrorMessage.textContent = "Please enter a valid full name with at least two words, each containing at least two letters.";
            }
        });

        fullNameInput.addEventListener("blur", function () {
            const value = fullNameInput.value;

            // Regular expression to allow only letters, spaces, and enforce at least two words
            const namePattern = /^[A-Za-z]{2,}(\s[A-Za-z]{2,})+$/;

            if (!namePattern.test(value)) {
                fullNameErrorMessage.textContent = "Please enter a valid full name with at least two words, each containing at least two letters.";
            } else {
                fullNameErrorMessage.textContent = ""; // Clear error message on valid input
            }
        });

        // ZIP Code Validation
        const zipCodeInput = document.getElementById("billingZipCode");
        const zipCodeErrorMessage = document.createElement("div");
        zipCodeErrorMessage.style.color = "red";
        zipCodeErrorMessage.style.fontSize = "12px";
        zipCodeErrorMessage.style.marginTop = "5px";
        zipCodeErrorMessage.id = "zipCodeError";
        zipCodeErrorMessage.textContent = ""; // Initially empty

        // Append the error message below the ZIP Code field
        zipCodeInput.parentNode.appendChild(zipCodeErrorMessage);

        zipCodeInput.addEventListener("input", function () {
            let value = zipCodeInput.value;

            // Limit input to 5 digits
            if (value.length > 5) {
                value = value.slice(0, 5);
                zipCodeInput.value = value;
            }

            // Regular expression to allow only 5-digit numbers
            const zipPattern = /^\d{5}$/;

            // Check if the input value matches the pattern
            if (zipPattern.test(value)) {
                zipCodeInput.style.borderColor = "green"; // Valid input style
                zipCodeErrorMessage.textContent = ""; // Clear error message
            } else {
                zipCodeInput.style.borderColor = "red"; // Invalid input style
                zipCodeErrorMessage.textContent = "Please enter a valid 5-digit ZIP Code.";
            }
        });

        zipCodeInput.addEventListener("blur", function () {
            const value = zipCodeInput.value;

            // Regular expression to allow only 5-digit numbers
            const zipPattern = /^\d{5}$/;

            if (!zipPattern.test(value)) {
                zipCodeErrorMessage.textContent = "Please enter a valid 5-digit ZIP Code.";
            } else {
                zipCodeErrorMessage.textContent = ""; // Clear error message on valid input
            }
        });
    });
    // Initialize Autocomplete when the DOM content loads
    document.addEventListener("DOMContentLoaded", initAutocomplete);

    
  
    document.addEventListener("DOMContentLoaded", () => {
        const stripe = Stripe("pk_test_51OjSIqCxMKfcbczj6MOFZD2lIahf0Ce97Bw38iArZp96x5TFGPnfUmwWvBIXzBArjH2tTwti2MYRcjehlq8ml1Db00jZT3kozc");
        
        
        const elements = stripe.elements();
        const card = elements.create("card", {
            style: {
                base: {
                    color: "black",
                    fontFamily: '"Helvetica Neue", Helvetica, Arial, sans-serif',
                    fontSize: "14px",
                    fontSmoothing: "antialiased",
                    "::placeholder": {
                        color: "gray",
                    },
                },
                invalid: {
                    color: "red",
                    iconColor: "red",
                },
            },
        });

        card.mount("#card-element");

        const form = document.getElementById("payment-form");
        const resultDiv = document.getElementById("payment-result");
        const hiddenAmountInput = document.getElementById("amount");

        function updateHiddenAmount() {
            const totalAmount = parseFloat(document.getElementById("s-totall").textContent) || 0.0;
            hiddenAmountInput.value = totalAmount.toFixed(2);
        }

        form.addEventListener("submit", async (event) => {
            event.preventDefault();
            updateHiddenAmount();

            const payload = {
                amount: hiddenAmountInput.value,
                billing_name: document.getElementById("billingFullName").value.trim(),
                billing_address_line1: document.getElementById("biAutoAdderss").value.trim(),
                billing_address_city: document.getElementById("billingCity").value.trim(),
                billing_address_state: document.getElementById("billingState").value.trim(),
                billing_address_zip: document.getElementById("billingZipCode").value.trim(),
                cartItems: JSON.parse(localStorage.getItem("cartItems")) || [],
                order_method: localStorage.getItem("orderMethod"),
                deliveryorpickup_date: localStorage.getItem("orderDate"),
                order_time: localStorage.getItem("orderTime"),
                order_address: localStorage.getItem("orderAddress"),
            };

            console.log("Payload sent to PaymentServlet:", payload);

            try {
                const paymentResponse = await fetch(`${window.location.origin}/com.foodUser/PaymentServlet`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(payload),
                });

                if (!paymentResponse.ok) {
                    const errorText = await paymentResponse.text();
                    throw new Error(`PaymentServlet error: ${errorText}`);
                }

                const paymentData = await paymentResponse.json();
                console.log("Response from PaymentServlet:", paymentData);

                if (paymentData.error) {
                    throw new Error(paymentData.error);
                }

                const { clientSecret, success } = paymentData;

                if (success) {
                    const { error, paymentIntent } = await stripe.confirmCardPayment(clientSecret, {
                        payment_method: {
                            card: card,
                            billing_details: {
                                name: payload.billing_name,
                                address: {
                                    line1: payload.billing_address_line1,
                                    city: payload.billing_address_city,
                                    state: payload.billing_address_state,
                                    postal_code: payload.billing_address_zip,
                                },
                            },
                        },
                    });

                    if (error) {
                    	throw new Error("Payment confirmation " + error.message);

                    }

                    if (paymentIntent && paymentIntent.status === "succeeded") {
                        console.log("Payment successful, proceeding to order confirmation...");

                        const confirmationResponse = await fetch(`${window.location.origin}/com.foodUser/OrderConfirmationServlet`, {
                            method: "POST",
                            headers: { "Content-Type": "application/json" },
                            body: JSON.stringify({ paymentIntentId: paymentIntent.id }),
                        });

                        if (!confirmationResponse.ok) {
                            const errorText = await confirmationResponse.text();
                            throw new Error(`OrderConfirmationServlet error: ${errorText}`);
                        }

                        const confirmationData = await confirmationResponse.json();
                        if (confirmationData.success) {
                            window.location.href = `${window.location.origin}/com.foodUser/jsp/OrderConfirmation.jsp`;
                        } else {
                            throw new Error(confirmationData.error);
                        }
                    }
                }
            } catch (err) {
                console.error("Error:", err.message);

                // Display a modal or inline error message
                const errorModal = document.getElementById("error-modal");
                errorModal.querySelector(".modal-body").textContent = err.message;
                errorModal.style.display = "block";

                // Close modal and refresh page on exit
                errorModal.querySelector(".close-btn").addEventListener("click", () => {
                    errorModal.style.display = "none";
                    window.location.reload();
                });
            }
        });

        updateHiddenAmount();
    });

    
    document.addEventListener("DOMContentLoaded", function () {
        const cartCountElement = document.querySelector('#navbar-cart-count');
        const storedCartItems = JSON.parse(localStorage.getItem('cartItems')) || [];
        const cartCount = storedCartItems.reduce((count, item) => count + item.quantity, 0);

        if (cartCountElement) {
            cartCountElement.innerText = cartCount;
        }
    });

    
    
    
    
    </script>
</body>

</html>