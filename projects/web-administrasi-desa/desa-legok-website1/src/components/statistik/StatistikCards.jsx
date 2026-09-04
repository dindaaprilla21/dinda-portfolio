export default function StatistikCards() {
    const cards = [
        {
            icon: "fas fa-users",
            value: "12.500+",
            label: "Jumlah Penduduk",
            gradient: "from-green-500 to-emerald-600",
            iconBg: "bg-gradient-to-br from-green-100 to-emerald-50",
            iconColor: "text-[var(--desa-main)]",
            borderColor: "border-green-600",
            shadowColor: "hover:shadow-green-200"
        },
        {
            icon: "fas fa-map-marked-alt",
            value: "8 RW",
            label: "Wilayah Administratif",
            gradient: "from-emerald-500 to-teal-600",
            iconBg: "bg-gradient-to-br from-emerald-100 to-teal-50",
            iconColor: "text-emerald-700",
            borderColor: "border-emerald-600",
            shadowColor: "hover:shadow-emerald-200"
        },
        {
            icon: "fas fa-hand-holding-heart",
            value: "24 Jam",
            label: "Siap Melayani",
            gradient: "from-teal-500 to-green-600",
            iconBg: "bg-gradient-to-br from-teal-100 to-green-50",
            iconColor: "text-teal-700",
            borderColor: "border-teal-600",
            shadowColor: "hover:shadow-teal-200"
        }
    ];

    return (
        <div className="py-8 md:py-12 px-4 md:px-8 lg:px-16">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 lg:gap-8">
                {cards.map((card, index) => (
                    <div
                        key={index}
                        className={`group relative bg-[#f1fff1] p-6 lg:p-8 rounded-2xl shadow-xl ${card.borderColor} border-b-4 
                                    flex items-center gap-4 lg:gap-6 
                                    transform transition-all duration-300 ease-out
                                    hover:scale-105 hover:-translate-y-2 hover:shadow-2xl ${card.shadowColor}
                                    cursor-pointer overflow-hidden`}
                    >
                        {/* Gradient Background Overlay on Hover */}
                        <div className={`absolute inset-0 bg-gradient-to-br ${card.gradient} opacity-0 group-hover:opacity-5 transition-opacity duration-300`}></div>

                        {/* Icon Container */}
                        <div className={`relative z-10 w-16 h-16 lg:w-20 lg:h-20 ${card.iconBg} rounded-2xl 
                                        flex items-center justify-center ${card.iconColor} text-2xl lg:text-3xl
                                        shadow-lg group-hover:shadow-xl
                                        transform group-hover:rotate-6 group-hover:scale-110
                                        transition-all duration-300`}>
                            <i className={card.icon}></i>
                        </div>

                        {/* Content */}
                        <div className="relative z-10 flex-1">
                            <h3 className="text-2xl lg:text-3xl font-bold text-gray-800 mb-1 
                                         group-hover:text-[var(--desa-main)] transition-colors duration-300">
                                {card.value}
                            </h3>
                            <p className="text-sm lg:text-base text-gray-600 font-medium">
                                {card.label}
                            </p>
                        </div>

                        {/* Decorative Corner Element */}
                        <div className={`absolute top-0 right-0 w-20 h-20 bg-gradient-to-br ${card.gradient} 
                                        opacity-0 group-hover:opacity-10 rounded-bl-full
                                        transition-opacity duration-300`}></div>
                    </div>
                ))}
            </div>
        </div>
    );
}